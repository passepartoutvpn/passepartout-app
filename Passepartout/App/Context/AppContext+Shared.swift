//
//  AppContext+Shared.swift
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

import AppData
import AppDataPreferences
import AppDataProfiles
import AppDataProviders
import CommonLibrary
import CommonUtils
import CoreData
import Foundation
import LegacyV2
import PassepartoutKit
import UIAccessibility
import UILibrary

extension AppContext {
    static let shared: AppContext = {
        let dependencies: Dependencies = .shared

        // MARK: Core Data

        guard let cdLocalModel = NSManagedObjectModel.mergedModel(from: [
            AppData.providersBundle
        ]) else {
            fatalError("Unable to load local model")
        }
        guard let cdRemoteModel = NSManagedObjectModel.mergedModel(from: [
            AppData.profilesBundle,
            AppData.preferencesBundle
        ]) else {
            fatalError("Unable to load remote model")
        }

        let localStore = CoreDataPersistentStore(
            logger: dependencies.coreDataLogger(),
            containerName: Constants.shared.containers.local,
            model: cdLocalModel,
            cloudKitIdentifier: nil,
            author: nil
        )
        let newRemoteStore: (_ cloudKit: Bool) -> CoreDataPersistentStore = {
            CoreDataPersistentStore(
                logger: dependencies.coreDataLogger(),
                containerName: Constants.shared.containers.remote,
                model: cdRemoteModel,
                cloudKitIdentifier: $0 ? BundleConfiguration.mainString(for: .cloudKitId) : nil,
                author: nil
            )
        }

        // MARK: Managers

        let iapManager = IAPManager(
            customUserLevel: dependencies.customUserLevel,
            inAppHelper: dependencies.simulatedAppProductHelper(),
            receiptReader: dependencies.simulatedAppReceiptReader(),
            betaChecker: dependencies.betaChecker(),
            productsAtBuild: dependencies.productsAtBuild()
        )
        let processor = dependencies.appProcessor(with: iapManager)

        let tunnelEnvironment = dependencies.tunnelEnvironment()
#if targetEnvironment(simulator)
        let tunnelStrategy = FakeTunnelStrategy(environment: tunnelEnvironment, dataCountInterval: 1000)
        let mainProfileRepository = dependencies.backupProfileRepository(
            model: cdRemoteModel,
            observingResults: true
        )
        let backupProfileRepository: ProfileRepository? = nil
#else
        let tunnelStrategy = NETunnelStrategy(
            bundleIdentifier: BundleConfiguration.mainString(for: .tunnelId),
            coder: dependencies.neProtocolCoder(),
            environment: tunnelEnvironment
        )
        let mainProfileRepository = NEProfileRepository(repository: tunnelStrategy) {
            dependencies.profileTitle($0)
        }
        let backupProfileRepository = dependencies.backupProfileRepository(
            model: cdRemoteModel,
            observingResults: false
        )
#endif

        let profileManager = ProfileManager(
            processor: processor,
            repository: mainProfileRepository,
            backupRepository: backupProfileRepository,
            mirrorsRemoteRepository: dependencies.mirrorsRemoteRepository,
            readyAfterRemote: true
        )

        let tunnel = ExtendedTunnel(
            defaults: .standard,
            tunnel: Tunnel(strategy: tunnelStrategy),
            environment: tunnelEnvironment,
            processor: processor,
            interval: Constants.shared.tunnel.refreshInterval
        )

        let apiManager: APIManager = {
            let repository = AppData.cdAPIRepositoryV3(context: localStore.backgroundContext())
            return APIManager(repository: repository)
        }()

        let migrationManager: MigrationManager = {
            let profileStrategy = ProfileV2MigrationStrategy(
                coreDataLogger: dependencies.coreDataLogger(),
                profilesContainer: .init(
                    Constants.shared.containers.legacyV2,
                    BundleConfiguration.mainString(for: .legacyV2CloudKitId)
                ),
                tvProfilesContainer: .init(
                    Constants.shared.containers.legacyV2TV,
                    BundleConfiguration.mainString(for: .legacyV2TVCloudKitId)
                )
            )
            let migrationSimulation: MigrationManager.Simulation?
            if AppCommandLine.contains(.fakeMigration) {
                migrationSimulation = MigrationManager.Simulation(
                    fakeProfiles: true,
                    maxMigrationTime: 3.0,
                    randomFailures: true
                )
            } else {
                migrationSimulation = nil
            }
            return MigrationManager(profileStrategy: profileStrategy, simulation: migrationSimulation)
        }()

        let preferencesManager = PreferencesManager()

        // MARK: Eligibility

        let onEligibleFeaturesBlock: (Set<AppFeature>) async -> Void = { @MainActor features in
            let isEligibleForSharing = features.contains(.sharing)
            let isRemoteImportingEnabled = isEligibleForSharing

            // toggle CloudKit sync based on .sharing eligibility
            let remoteStore = newRemoteStore(isRemoteImportingEnabled)

            // @Published
            profileManager.isRemoteImportingEnabled = isRemoteImportingEnabled

            do {
                pp_log(.app, .info, "\tRefresh remote sync (eligible=\(isEligibleForSharing), CloudKit=\(isCloudKitEnabled))...")

                pp_log(.App.profiles, .info, "\tRefresh remote profiles repository (sync=\(isRemoteImportingEnabled))...")
                try await profileManager.observeRemote(repository: {
                    AppData.cdProfileRepositoryV3(
                        registry: dependencies.registry,
                        coder: dependencies.profileCoder(),
                        context: remoteStore.context,
                        observingResults: true,
                        onResultError: {
                            pp_log(.App.profiles, .error, "Unable to decode remote profile: \($0)")
                            return .ignore
                        }
                    )
                }())

                pp_log(.app, .info, "\tRefresh modules preferences repository...")
                preferencesManager.modulesRepositoryFactory = {
                    try AppData.cdModulePreferencesRepositoryV3(
                        context: remoteStore.context,
                        moduleId: $0
                    )
                }

                pp_log(.app, .info, "\tRefresh providers preferences repository...")
                preferencesManager.providersRepositoryFactory = {
                    try AppData.cdProviderPreferencesRepositoryV3(
                        context: remoteStore.context,
                        providerId: $0
                    )
                }
            } catch {
                pp_log(.App.profiles, .error, "\tUnable to re-observe remote profiles: \(error)")
            }

            pp_log(.App.profiles, .info, "\tReload profiles required features...")
            profileManager.reloadRequiredFeatures()
        }

        // MARK: Build

        return AppContext(
            apiManager: apiManager,
            iapManager: iapManager,
            migrationManager: migrationManager,
            preferencesManager: preferencesManager,
            profileManager: profileManager,
            registry: dependencies.registry,
            tunnel: tunnel,
            onEligibleFeaturesBlock: onEligibleFeaturesBlock
        )
    }()
}

private extension AppContext {
    static var isCloudKitEnabled: Bool {
#if os(tvOS)
        true
#else
        if AppCommandLine.contains(.uiTesting) {
            return true
        }
        return FileManager.default.ubiquityIdentityToken != nil
#endif
    }
}

// MARK: - Dependencies

private extension Dependencies {
    func simulatedAppProductHelper() -> any AppProductHelper {
        if AppCommandLine.contains(.fakeIAP) {
            return FakeAppProductHelper()
        }
        return appProductHelper()
    }

    func simulatedAppReceiptReader() -> AppReceiptReader {
        if AppCommandLine.contains(.fakeIAP) {
            guard let mockHelper = simulatedAppProductHelper() as? FakeAppProductHelper else {
                fatalError("When .isFakeIAP, simulatedInAppHelper is expected to be MockAppProductHelper")
            }
            return mockHelper.receiptReader
        }
        return SharedReceiptReader(
            reader: StoreKitReceiptReader(logger: iapLogger())
        )
    }

    var mirrorsRemoteRepository: Bool {
#if os(tvOS)
        true
#else
        false
#endif
    }

    func backupProfileRepository(model: NSManagedObjectModel, observingResults: Bool) -> ProfileRepository {
        let store = CoreDataPersistentStore(
            logger: coreDataLogger(),
            containerName: Constants.shared.containers.backup,
            model: model,
            cloudKitIdentifier: nil,
            author: nil
        )
        return AppData.cdProfileRepositoryV3(
            registry: registry,
            coder: profileCoder(),
            context: store.context,
            observingResults: observingResults,
            onResultError: {
                pp_log(.App.profiles, .error, "Unable to decode local profile: \($0)")
                return .ignore
            }
        )
    }
}
