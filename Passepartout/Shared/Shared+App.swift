//
//  Shared+App.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/24/24.
//  Copyright (c) 2024 Davide De Rosa. All rights reserved.
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

import AppData
import AppDataProfiles
import AppLibrary
import CommonLibrary
import CoreData
import Foundation
import PassepartoutKit
import UtilsLibrary

extension AppContext {
    static let shared = AppContext(
        iapManager: .shared,
        profileManager: .shared,
        tunnel: .shared,
        tunnelEnvironment: .shared,
        registry: .shared,
        constants: .shared
    )
}

extension IAPManager {
    static let shared = IAPManager(
        customUserLevel: customUserLevel,
        receiptReader: KvittoReceiptReader(),
        productsAtBuild: productsAtBuild
    )

    private static var customUserLevel: AppUserLevel? {
        if let envString = ProcessInfo.processInfo.environment["CUSTOM_USER_LEVEL"],
           let envValue = Int(envString),
           let testAppType = AppUserLevel(rawValue: envValue) {

            return testAppType
        }
        if let infoValue = BundleConfiguration.main.integerIfPresent(for: .customUserLevel),
           let testAppType = AppUserLevel(rawValue: infoValue) {

            return testAppType
        }
        return nil
    }

    private static let productsAtBuild: BuildProducts<AppProduct> = {
#if os(iOS)
        if $0 <= 2016 {
            return [.Full.iOS]
        } else if $0 <= 3000 {
            return [.Features.networkSettings]
        }
        return []
#elseif os(macOS)
        if $0 <= 3000 {
            return [.Features.networkSettings]
        }
        return []
#else
        return []
#endif
    }
}

extension ProfileManager {
    static let shared: ProfileManager = {
        let model = AppData.cdProfilesModel

        let store = CoreDataPersistentStore(
            logger: .default,
            containerName: BundleConfiguration.main.string(for: .profilesContainerName),
            model: model,
            cloudKit: false,
            cloudKitIdentifier: nil,
            author: nil
        )

        let repository = AppData.cdProfileRepository(
            registry: .shared,
            coder: CodableProfileCoder(),
            context: store.context
        ) { error in
            pp_log(.app, .error, "Unable to decode result: \(error)")
            return true
        }

        return ProfileManager(repository: repository)
    }()
}

#if targetEnvironment(simulator)

extension Tunnel {
    static let shared = Tunnel(
        strategy: FakeTunnelStrategy(environment: .shared, dataCountInterval: 1000)
    )
}

#else

extension Tunnel {
    static let shared = Tunnel(
        strategy: NETunnelStrategy(
            bundleIdentifier: BundleConfiguration.main.string(for: .tunnelId),
            encoder: .shared
        )
    )
}

#endif
