//
//  AppContext+Previews.swift
//  Passepartout
//
//  Created by Davide De Rosa on 6/22/24.
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
import CommonUtils
import Foundation
import PassepartoutKit

extension AppContext {
    public static let forPreviews: AppContext = {
        let iapManager = IAPManager(
            customUserLevel: .fullV3,
            inAppHelper: FakeAppProductHelper(),
            receiptReader: FakeAppReceiptReader(),
            betaChecker: TestFlightChecker(),
            productsAtBuild: { _ in
                []
            }
        )
        let processor = MockAppProcessor(iapManager: iapManager)
        let profileManager = {
            let profiles: [Profile] = (0..<20)
                .reduce(into: []) { list, _ in
                    list.append(.newMockProfile())
                }
            return ProfileManager(profiles: profiles)
        }()
        let tunnelEnvironment = InMemoryEnvironment()
        let tunnel = ExtendedTunnel(
            tunnel: Tunnel(strategy: FakeTunnelStrategy(environment: tunnelEnvironment)),
            environment: tunnelEnvironment,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )
        let apiManager = APIManager(
            repository: InMemoryAPIRepository()
        )
        let migrationManager = MigrationManager()
        return AppContext(
            apiManager: apiManager,
            iapManager: iapManager,
            migrationManager: migrationManager,
            preferencesManager: PreferencesManager(),
            profileManager: profileManager,
            registry: Registry(),
            tunnel: tunnel
        )
    }()
}

// MARK: - Shortcuts

extension IAPManager {
    public static var forPreviews: IAPManager {
        AppContext.forPreviews.iapManager
    }
}

extension ProfileManager {
    public static var forPreviews: ProfileManager {
        AppContext.forPreviews.profileManager
    }
}

extension ExtendedTunnel {
    public static var forPreviews: ExtendedTunnel {
        AppContext.forPreviews.tunnel
    }
}

extension APIManager {
    public static var forPreviews: APIManager {
        AppContext.forPreviews.apiManager
    }
}
