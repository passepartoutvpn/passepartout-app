//
//  PacketTunnelProvider.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
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

import CommonLibrary
@preconcurrency import NetworkExtension
import PassepartoutKit

final class PacketTunnelProvider: NEPacketTunnelProvider, @unchecked Sendable {

    @MainActor
    private let context: TunnelContext = .shared

    @MainActor
    private let dependencies: Dependencies = .shared

    private var fwd: NEPTPForwarder?

    override func startTunnel(options: [String: NSObject]? = nil) async throws {
        PassepartoutConfiguration.shared.configureLogging(
            to: BundleConfiguration.urlForTunnelLog,
            parameters: Constants.shared.log,
            logsPrivateData: UserDefaults.appGroup.bool(forKey: AppPreference.logsPrivateData.key)
        )
        pp_log(.app, .info, "Tunnel started with options: \(options?.description ?? "nil")")

        let environment = await dependencies.tunnelEnvironment()

        // check hold flag
        if environment.environmentValue(forKey: TunnelEnvironmentKeys.holdFlag) == true {
            pp_log(.app, .info, "Tunnel is on hold")
            guard options?[ExtendedTunnel.isManualKey] == true as NSNumber else {
                pp_log(.app, .error, "Tunnel was started non-interactively, hang here")
                return
            }
            pp_log(.app, .info, "Tunnel was started interactively, clear hold flag")
            environment.removeEnvironmentValue(forKey: TunnelEnvironmentKeys.holdFlag)
        }

        do {
            fwd = try await NEPTPForwarder(
                provider: self,
                decoder: dependencies.neProtocolCoder(),
                registry: dependencies.registry,
                environment: environment,
                willProcess: context.processor.willProcess
            )
            guard let fwd else {
                fatalError("NEPTPForwarder nil without throwing error?")
            }

            await context.iapManager.fetchLevelIfNeeded()
            let params = await Constants.shared.tunnel.verificationParameters(isBeta: context.iapManager.isBeta)
            pp_log(.app, .info, "Will start profile verification in \(params.delay) seconds")

            try await fwd.startTunnel(options: options)

            // #1070, do not wait for this to start the tunnel. if on-demand is
            // enabled, networking will stall and StoreKit network calls may
            // produce a deadlock
            Task {
                try? await Task.sleep(for: .seconds(params.delay))
                await verifyEligibility(
                    of: fwd.profile,
                    environment: environment,
                    interval: params.interval
                )
            }
        } catch {
            pp_log(.app, .fault, "Unable to start tunnel: \(error)")
            PassepartoutConfiguration.shared.flushLog()
            throw error
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason) async {
        await fwd?.stopTunnel(with: reason)
        fwd = nil
        PassepartoutConfiguration.shared.flushLog()
    }

    override func cancelTunnelWithError(_ error: (any Error)?) {
        PassepartoutConfiguration.shared.flushLog()
        super.cancelTunnelWithError(error)
    }

    override func handleAppMessage(_ messageData: Data) async -> Data? {
        await fwd?.handleAppMessage(messageData)
    }

    override func wake() {
        fwd?.wake()
    }

    override func sleep() async {
        await fwd?.sleep()
    }
}

// MARK: - Eligibility

private extension PacketTunnelProvider {
    func verifyEligibility(of profile: Profile, environment: TunnelEnvironment, interval: TimeInterval) async {
        while true {
            do {
                pp_log(.app, .info, "Verify profile, requires: \(profile.features)")
                await context.iapManager.reloadReceipt()
                try await context.iapManager.verify(profile)
            } catch {
                let error = PassepartoutError(.App.ineligibleProfile)
                environment.setEnvironmentValue(error.code, forKey: TunnelEnvironmentKeys.lastErrorCode)
                pp_log(.app, .fault, "Verification failed for profile \(profile.id), shutting down: \(error)")

                // prevent on-demand reconnection
                environment.setEnvironmentValue(true, forKey: TunnelEnvironmentKeys.holdFlag)
                await fwd?.holdTunnel()
                return
            }

            pp_log(.app, .info, "Will verify profile again in \(interval) seconds...")
            try? await Task.sleep(interval: interval)
        }
    }
}

private extension TunnelEnvironmentKeys {
    static let holdFlag = TunnelEnvironmentKey<Bool>("Tunnel.onHold")
}
