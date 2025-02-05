//
//  ExtendedTunnel.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/7/24.
//  Copyright (c) 2025 Davide De Rosa. All rights reserved.
//
//  https://github.com/passepartoutvpn
//
//  This file is part of Passepartout.
//
//  Passepartout is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Passepartout is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Passepartout.  If not, see <http://www.gnu.org/licenses/>.
//

import Combine
import Foundation
import PassepartoutKit

@MainActor
public final class ExtendedTunnel: ObservableObject {
    public static nonisolated let isManualKey = "isManual"

    private let defaults: UserDefaults?

    private let tunnel: Tunnel

    private let environment: TunnelEnvironment

    private let processor: AppTunnelProcessor?

    private let interval: TimeInterval

    public func value<T>(forKey key: TunnelEnvironmentKey<T>) -> T? where T: Decodable {
        environment.environmentValue(forKey: key)
    }

    @Published
    public private(set) var lastErrorCode: PassepartoutError.Code? {
        didSet {
            pp_log(.app, .info, "ExtendedTunnel.lastErrorCode -> \(lastErrorCode?.rawValue ?? "nil")")
        }
    }

    @Published
    public private(set) var dataCount: DataCount?

    private var subscriptions: Set<AnyCancellable>

    public init(
        defaults: UserDefaults? = nil,
        tunnel: Tunnel,
        environment: TunnelEnvironment,
        processor: AppTunnelProcessor? = nil,
        interval: TimeInterval
    ) {
        self.defaults = defaults
        self.tunnel = tunnel
        self.environment = environment
        self.processor = processor
        self.interval = interval
        subscriptions = []

        observeObjects()
    }
}

// MARK: - Public interface

extension ExtendedTunnel {
    public var status: TunnelStatus {
        tunnel.status
    }

    public var connectionStatus: TunnelStatus {
        tunnel.status.withEnvironment(environment)
    }
}

extension ExtendedTunnel {
    public var currentProfile: TunnelCurrentProfile? {
        tunnel.currentProfile ?? lastUsedProfile
    }

    public var currentProfilePublisher: AnyPublisher<TunnelCurrentProfile?, Never> {
        tunnel
            .$currentProfile
            .map {
                $0 ?? self.lastUsedProfile
            }
            .eraseToAnyPublisher()
    }

    public func install(_ profile: Profile) async throws {
        pp_log(.app, .notice, "Install profile \(profile.id)...")
        let newProfile = try processedProfile(profile)
        try await tunnel.install(
            newProfile,
            connect: false,
            options: .init(values: [Self.isManualKey: true as NSNumber]),
            title: processedTitle
        )
    }

    public func connect(with profile: Profile, force: Bool = false) async throws {
        pp_log(.app, .notice, "Connect to profile \(profile.id)...")
        let newProfile = try processedProfile(profile)
        if !force && newProfile.isInteractive {
            throw AppError.interactiveLogin
        }
        try await tunnel.install(
            newProfile,
            connect: true,
            options: .init(values: [Self.isManualKey: true as NSNumber]),
            title: processedTitle
        )
    }

    public func disconnect() async throws {
        pp_log(.app, .notice, "Disconnect...")
        try await tunnel.disconnect()
    }

    public func currentLog(parameters: Constants.Log) async -> [String] {
        let output = try? await tunnel.sendMessage(.localLog(
            sinceLast: parameters.sinceLast,
            maxLevel: parameters.options.maxLevel
        ))
        switch output {
        case .debugLog(let log):
            return log.lines.map(parameters.formatter.formattedLine)

        default:
            return []
        }
    }
}

// MARK: - Observation

private extension ExtendedTunnel {
    func observeObjects() {
        tunnel
            .$status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else {
                    return
                }
                switch $0 {
                case .activating:
                    lastErrorCode = nil

                default:
                    lastErrorCode = value(forKey: TunnelEnvironmentKeys.lastErrorCode)
                }
                if $0 != .active {
                    dataCount = nil
                }
            }
            .store(in: &subscriptions)

        tunnel
            .$currentProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                if let id = $0?.id {
                    self?.defaults?.set(id.uuidString, forKey: AppPreference.lastUsedProfileId.key)
                }
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)

        Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                if let lastErrorCode = value(forKey: TunnelEnvironmentKeys.lastErrorCode),
                    lastErrorCode != self.lastErrorCode {
                    self.lastErrorCode = lastErrorCode
                }
                if tunnel.status == .active {
                    dataCount = value(forKey: TunnelEnvironmentKeys.dataCount)
                }
            }
            .store(in: &subscriptions)
    }
}

// MARK: - Processing

private extension ExtendedTunnel {
    var processedTitle: (Profile) -> String {
        if let processor {
            return processor.title
        }
        return \.name
    }

    func processedProfile(_ profile: Profile) throws -> Profile {
        if let processor {
            return try processor.willInstall(profile)
        }
        return profile
    }
}

// MARK: - Helpers

private extension ExtendedTunnel {
    var lastUsedProfile: TunnelCurrentProfile? {
        guard let uuidString = defaults?.object(forKey: AppPreference.lastUsedProfileId.key) as? String,
              let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        return TunnelCurrentProfile(id: uuid, onDemand: false)
    }
}

extension TunnelStatus {
    func withEnvironment(_ environment: TunnelEnvironment) -> TunnelStatus {
        var status = self
        if status == .active, let connectionStatus = environment.environmentValue(forKey: TunnelEnvironmentKeys.connectionStatus) {
            switch connectionStatus {
            case .connecting:
                status = .activating
            case .connected:
                status = .active
            case .disconnecting:
                status = .deactivating
            case .disconnected:
                status = .inactive
            }
        }
        return status
    }
}
