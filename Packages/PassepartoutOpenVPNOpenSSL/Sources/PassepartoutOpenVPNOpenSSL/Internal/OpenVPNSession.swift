//
//  OpenVPNSession.swift
//  PassepartoutKit
//
//  Created by Davide De Rosa on 2/3/17.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of PassepartoutKit.
//
//  PassepartoutKit is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  PassepartoutKit is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with PassepartoutKit.  If not, see <http://www.gnu.org/licenses/>.
//

internal import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit

/// Default implementation of ``OpenVPNSessionProtocol``.
actor OpenVPNSession {
    enum SessionState {
        case stopped

        case starting

        case started

        case stopping
    }

    // MARK: Init

    private let configuration: OpenVPN.Configuration

    private let credentials: OpenVPN.Credentials?

    private let prng: PRNGProtocol

    private let tlsFactory: () -> OpenVPNTLSProtocol

    private let cryptoFactory: () -> OpenVPNCryptoProtocol

    private let caURL: URL

    let options: Options

    let tlsOptions: OpenVPNTLSOptions

    // MARK: Persistent state

    private let controlChannel: ControlChannel

    private var tlsObserver: NSObjectProtocol?

    private weak var delegate: OpenVPNSessionDelegate?

    // MARK: State

    private var sessionState: SessionState

    private(set) var tunnel: TunnelInterface?

    private(set) var link: LinkInterface?

    private var negotiators: [UInt8: Negotiator]

    private var dataChannels: [UInt8: DataChannel]

    private var oldKeys: [UInt8]

    private var currentNegotiatorKey: UInt8? {
        didSet {
            pp_log(.openvpn, .info, "Negotiator: Current key is \(currentNegotiatorKey?.description ?? "nil")")
        }
    }

    private var currentDataChannelKey: UInt8? {
        didSet {
            pp_log(.openvpn, .info, "Data: Current key is \(currentDataChannelKey?.description ?? "nil")")
        }
    }

    private var withLocalOptions: Bool

    private var pushReply: PushReply?

    private var pendingPingTask: Task<Void, Error>?

    private var lastReceivedDate: Date?

    private var lastDataCountDate: Date?

    private var dataCount: BidirectionalState<Int>

    // MARK: Init

    /**
     Creates a VPN session.

     - Parameters:
       - configuration: The `Configuration` to use for this session.
       - credentials: The optional credentials.
       - prng: The pseudo-random number generator.
       - tlsFactory: The TLS implementation.
       - cryptoFactory: The cryptographic implementation.
       - cachesURL: The URL of the folder where to store cache files.
       - options: Options for fine-tuning.
     - Precondition: `configuration.ca` must be non-nil.
     - Throws: If cryptographic or TLS initialization fails.
     */
    init(
        configuration: OpenVPN.Configuration,
        credentials: OpenVPN.Credentials?,
        prng: PRNGProtocol,
        tlsFactory: @escaping @Sendable () -> OpenVPNTLSProtocol,
        cryptoFactory: @escaping @Sendable () -> OpenVPNCryptoProtocol,
        cachesURL: URL,
        options: Options = .init()
    ) throws {
        guard let ca = configuration.ca else {
            fatalError("Configuration has no CA")
        }
        self.configuration = configuration
        self.credentials = try credentials?.forAuthentication()
        self.prng = prng
        self.tlsFactory = tlsFactory
        self.cryptoFactory = cryptoFactory
        caURL = cachesURL.appendingPathComponent(Caches.ca)
        self.options = options

        try ca.write(to: caURL)
        tlsOptions = OpenVPNTLSOptions(
            bufferLength: OpenVPNTLSOptionsDefaultBufferLength,
            caURL: caURL,
            clientCertificatePEM: configuration.clientCertificate?.pem,
            clientKeyPEM: configuration.clientKey?.pem,
            checksEKU: configuration.checksEKU ?? false,
            checksSANHost: configuration.checksSANHost ?? false,
            hostname: configuration.sanHost,
            securityLevel: configuration.tlsSecurityLevel ?? 0
        )

        controlChannel = try cryptoFactory().newControlChannel(with: prng, configuration: configuration)
        negotiators = [:]
        dataChannels = [:]
        oldKeys = []

        sessionState = .stopped
        withLocalOptions = true
        dataCount = BidirectionalState(withResetValue: 0)
    }

    deinit {
        try? FileManager.default.removeItem(at: caURL)
    }
}

// MARK: - Options

extension OpenVPNSession {

    /// The options for ``OpenVPNSession``. Intervals are expressed in seconds.
    struct Options: Sendable {
        var maxPackets: Int = 100

        var writeTimeout: TimeInterval = 5.0

        var minDataCountInterval: TimeInterval = 3.0

        var negotiationTimeout: TimeInterval = 30.0

        var hardResetTimeout: TimeInterval = 10.0

        var tickInterval: TimeInterval = 0.2

        var retxInterval: TimeInterval = 0.1

        var pushRequestInterval: TimeInterval = 2.0

        var pingTimeoutCheckInterval: TimeInterval = 10.0

        var pingTimeout: TimeInterval = 120.0

        var softNegotiationTimeout: TimeInterval = 120.0

        init() {
        }
    }
}

// MARK: - Public API

extension OpenVPNSession: OpenVPNSessionProtocol {
    func setDelegate(_ delegate: OpenVPNSessionDelegate) async {
        self.delegate = delegate
    }

    func setTunnel(_ tunnel: TunnelInterface) {
        guard self.tunnel == nil else {
            pp_log(.openvpn, .error, "Tunnel interface already set")
            return
        }

        pp_log(.openvpn, .info, "Start TUN loop")

        self.tunnel = tunnel
        loopTunnel()
    }

    func setLink(_ link: LinkInterface) async throws {
        guard self.link == nil else {
            pp_log(.openvpn, .error, "Link interface already set")
            return
        }

        pp_log(.openvpn, .info, "Start VPN session")

        self.link = link
        sessionState = .starting

        try await startNegotiation(on: link)
    }

    func hasLink() async -> Bool {
        link != nil
    }

    func shutdown(_ error: Error?, timeout: TimeInterval?) async {
        guard sessionState != .stopping, sessionState != .stopped else {
            pp_log(.openvpn, .error, "Ignore stop request, stopped or already stopping")
            return
        }

        if let error {
            pp_log(.openvpn, .error, "Shut down with failure: \(error)")
        } else {
            pp_log(.openvpn, .info, "Shut down on request")
        }
        sessionState = .stopping

        // shut down after sending exit notification if link is unreliable (normally UDP)
        if error == nil || (error as? PassepartoutError)?.code == .networkChanged,
           let link, !link.isReliable,
           let currentDataChannel {
            do {
                if let packets = try await currentDataChannel.encrypt(packets: [OCCPacket.exit.serialized()]) {
                    pp_log(.openvpn, .info, "Send OCCPacket exit")

                    let timeoutMillis = Int((timeout ?? options.writeTimeout) * 1000.0)

                    let writeTask = Task {
                        try await link.writePackets(packets)
                        try Task.checkCancellation()
                    }
                    let timeoutTask = Task {
                        try await Task.sleep(milliseconds: timeoutMillis)
                        try Task.checkCancellation()
                        pp_log(.openvpn, .info, "Cancelled OCCPacket")
                        writeTask.cancel()
                    }
                    try await writeTask.value
                    timeoutTask.cancel()

                    pp_log(.openvpn, .info, "Sent OCCPacket correctly")
                }
            } catch {
                pp_log(.openvpn, .error, "Unable to send OCCPacket exit: \(error)")
            }
        }

        await cleanup()
        sessionState = .stopped

        // retry authentication without local otpions
        if case .badCredentialsWithLocalOptions = error as? OpenVPNSessionError {
            withLocalOptions = false
        }

        await delegate?.sessionDidStop(self, withError: error)
    }
}

private extension OpenVPNSession {
    func cleanup() async {
        link?.shutdown()
        for neg in negotiators.values {
            await neg.cancel()
        }
        negotiators.removeAll()
        dataChannels.removeAll()
        oldKeys.removeAll()
        pendingPingTask?.cancel()
        dataCount.reset()

        link = nil
        currentNegotiatorKey = nil
        currentDataChannelKey = nil
        pushReply = nil
        pendingPingTask = nil
        lastDataCountDate = nil
    }
}

// MARK: - Private API

extension OpenVPNSession {
    var isStopped: Bool {
        sessionState == .stopped
    }

    var currentNegotiator: Negotiator? {
        guard let key = currentNegotiatorKey else {
            return nil
        }
        return negotiators[key]
    }

    var currentDataChannel: DataChannel? {
        guard let key = currentDataChannelKey else {
            return nil
        }
        return dataChannels[key]
    }

    func newNegotiator(on link: LinkInterface) -> Negotiator {
        let negOptions = Negotiator.Options(
            configuration: configuration,
            credentials: credentials,
            withLocalOptions: withLocalOptions,
            sessionOptions: options,
            tlsOptions: tlsOptions,
            onConnected: { [weak self] key, dataChannel, pushReply in
                await self?.didNegotiate(
                    key: key,
                    dataChannel: dataChannel,
                    pushReply: pushReply
                )
            },
            onError: { [weak self] _, error in
                await self?.shutdown(error)
            }
        )
        return Negotiator(
            link: link,
            channel: controlChannel,
            prng: prng,
            tlsFactory: tlsFactory,
            cryptoFactory: cryptoFactory,
            options: negOptions
        )
    }

    func addNegotiator(_ negotiator: Negotiator) {
        pp_log(.openvpn, .info, "Replace negotiator with key \(negotiator.key)")
        negotiators[negotiator.key] = negotiator
        pp_log(.openvpn, .info, "Negotiators: \(negotiators.keys)")
        currentNegotiatorKey = negotiator.key
    }

    func didNegotiate(
        key: UInt8,
        dataChannel: DataChannel,
        pushReply: PushReply
    ) {
        pp_log(.openvpn, .info, "Negotiation succeeded, set key \(key) as current")

        self.pushReply = pushReply

        // replace current channel with new
        pp_log(.openvpn, .info, "Replace key \(dataChannel.key) with new data channel")
        dataChannels[dataChannel.key] = dataChannel
        if let currentDataChannel {
            oldKeys.append(currentDataChannel.key)
        }
        currentDataChannelKey = key

        // clean up old keys
        while oldKeys.count > 1 {
            let keyToRemove = oldKeys.removeFirst()
            pp_log(.openvpn, .info, "Remove key \(keyToRemove) from negotiators and data channels")
            negotiators.removeValue(forKey: keyToRemove)
            dataChannels.removeValue(forKey: keyToRemove)
        }
        pp_log(.openvpn, .info, "Negotiators: \(negotiators.keys)")
        pp_log(.openvpn, .info, "Data channels: \(dataChannels.keys)")

        // renegotiation stops here
        guard sessionState != .started else {
            return
        }

        sessionState = .started
        Task {
            guard let remoteAddress = link?.remoteAddress,
                  let remoteProtocol = link?.remoteProtocol else {
                pp_log(.openvpn, .fault, "Unable to resolve link remote address/protocol")
                await shutdown(OpenVPNSessionError.assertion)
                return
            }
            await delegate?.sessionDidStart(
                self,
                remoteAddress: remoteAddress,
                remoteProtocol: remoteProtocol,
                remoteOptions: pushReply.options
            )
        }
        scheduleNextPing()
    }

    func hasDataChannel(for key: UInt8) -> Bool {
        dataChannels[key] != nil
    }

    func dataChannel(for key: UInt8) -> DataChannel? {
        dataChannels[key]
    }

    func reportLastReceivedDate() {
        lastReceivedDate = Date()
    }

    func reportInboundDataCount(_ count: Int) {
        dataCount.inbound += count
        delegateCurrentDataCount()
    }

    func reportOutboundDataCount(_ count: Int) {
        dataCount.outbound += count
        delegateCurrentDataCount()
    }

    func checkPingTimeout() throws {
        if let lastReceivedDate {
            guard -lastReceivedDate.timeIntervalSinceNow <= keepAliveTimeout else {
                throw OpenVPNSessionError.pingTimeout
            }
        }
    }
}

extension OpenVPNSession {

    @discardableResult
    nonisolated func runInActor(after: TimeInterval? = nil, _ block: @escaping () async throws -> Void) -> Task<Void, Error> {
        Task {
            if let after {
                try await Task.sleep(interval: after)
            }
            guard !Task.isCancelled else {
                return
            }
            try await block()
        }
    }
}

// MARK: - Helpers

private extension OpenVPNSession {
    enum Caches {
        static let ca = "ca.pem"
    }

    func scheduleNextPing() {
        let interval = keepAliveInterval ?? options.pingTimeoutCheckInterval
        pp_log(.openvpn, .debug, "Schedule ping check after \(interval.asTimeString)")

        pendingPingTask?.cancel()
        pendingPingTask = runInActor(after: interval) { [weak self] in
            do {
                try await self?.ping()
            } catch {
                await self?.shutdown(error)
            }
        }
    }

    func ping() async throws {
        guard !isStopped else {
            pp_log(.openvpn, .debug, "Ping cancelled, session stopped")
            return
        }
        guard let link else {
            pp_log(.openvpn, .debug, "Ping cancelled, no link")
            return
        }
        guard let currentDataChannel else {
            pp_log(.openvpn, .debug, "Ping cancelled, no data channel")
            return
        }

        pp_log(.openvpn, .debug, "Run ping check")
        try checkPingTimeout()

        // is keep-alive enabled?
        if keepAliveInterval != nil {
            pp_log(.openvpn, .debug, "Send ping")
            try await sendDataPackets(
                [ProtocolMacros.pingString],
                to: link,
                dataChannel: currentDataChannel
            )
        }

        // schedule even just to check for ping timeout
        scheduleNextPing()
    }

    var keepAliveInterval: TimeInterval? {
        let interval: TimeInterval?
        if let negInterval = pushReply?.options.keepAliveInterval, negInterval > 0.0 {
            interval = negInterval
        } else if let cfgInterval = configuration.keepAliveInterval, cfgInterval > 0.0 {
            interval = cfgInterval
        } else {
            return nil
        }
        return interval
    }

    var keepAliveTimeout: TimeInterval {
        if let negTimeout = pushReply?.options.keepAliveTimeout, negTimeout > 0.0 {
            return negTimeout
        } else if let cfgTimeout = configuration.keepAliveTimeout, cfgTimeout > 0.0 {
            return cfgTimeout
        } else {
            return options.pingTimeout
        }
    }

    func delegateCurrentDataCount() {
        if let lastDataCountDate {
            guard -lastDataCountDate.timeIntervalSinceNow >= options.minDataCountInterval else {
                return
            }
        }
        lastDataCountDate = Date()
        Task {
            await delegate?.session(self, didUpdateDataCount: .init(UInt(dataCount.inbound), UInt(dataCount.outbound)))
        }
    }
}

private extension OpenVPNCryptoProtocol {
    func newControlChannel(
        with prng: PRNGProtocol,
        configuration: OpenVPN.Configuration
    ) throws -> ControlChannel {
        let channel: ControlChannel
        if let tlsWrap = configuration.tlsWrap {
            switch tlsWrap.strategy {
            case .auth:
                channel = try ControlChannel(
                    prng: prng,
                    crypto: self,
                    authKey: tlsWrap.key,
                    digest: configuration.fallbackDigest
                )

            case .crypt:
                channel = try ControlChannel(
                    prng: prng,
                    crypto: self,
                    cryptKey: tlsWrap.key
                )
            }
        } else {
            channel = ControlChannel(prng: prng)
        }
        return channel
    }
}
