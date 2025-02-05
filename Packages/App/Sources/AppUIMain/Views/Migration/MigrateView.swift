//
//  MigrateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/13/24.
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
import PassepartoutKit
import SwiftUI

// TODO: #878, show CloudKit progress

struct MigrateView: View {
    enum Style {
        case list

        case table
    }

    @EnvironmentObject
    private var migrationManager: MigrationManager

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.dismiss)
    private var dismiss

    let style: Style

    @ObservedObject
    var profileManager: ProfileManager

    @State
    private var model = Model()

    @State
    private var isEditing = false

    @State
    private var isDeleting = false

    @State
    private var profilesPendingDeletion: [MigratableProfile]?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        debugChanges()
        return MigrateContentView(
            style: style,
            step: model.step,
            profiles: model.visibleProfiles,
            statuses: $model.statuses,
            isEditing: $isEditing,
            onDelete: onDelete,
            performButton: performButton
        )
        .themeProgress(if: !model.step.isReady)
        .themeAnimation(on: model, category: .profiles)
        .themeConfirmation(
            isPresented: $isDeleting,
            title: Strings.Views.Migration.Items.discard,
            message: messageForDeletion,
            isDestructive: true,
            action: confirmPendingDeletion
        )
        .navigationTitle(title)
        .task {
            await fetch()
        }
        .withErrorHandler(errorHandler)
    }
}

private extension MigrateView {
    var title: String {
        Strings.Views.Migration.title
    }

    var messageForDeletion: String? {
        profilesPendingDeletion.map {
            let nameList = $0
                .map(\.name)
                .joined(separator: "\n")

            return Strings.Views.Migration.Alerts.Delete.message(nameList)
        }
    }

    func performButton() -> some View {
        MigrateButton(step: model.step) {
            Task {
                await perform(at: model.step)
            }
        }
    }
}

private extension MigrateView {
    func onDelete(_ profiles: [MigratableProfile]) {
        profilesPendingDeletion = profiles
        isDeleting = true
    }

    func perform(at step: MigrateViewStep) async {
        switch step {
        case .fetched(let profiles):
            await migrate(profiles)

        case .migrated:
            dismiss()

        default:
            assertionFailure("No action allowed at step \(step), why is button enabled?")
        }
    }

    func fetch() async {
        guard model.step == .initial else {
            return
        }
        do {
            model.step = .fetching
            pp_log(.App.migration, .notice, "Fetch migratable profiles...")
            let migratable = try await migrationManager.fetchMigratableProfiles()
            let knownIDs = Set(profileManager.previews.map(\.id))
            model.profiles = migratable.filter {
                !knownIDs.contains($0.id)
            }
            model.step = .fetched(model.profiles)
        } catch {
            pp_log(.App.migration, .error, "Unable to fetch migratable profiles: \(error)")
            errorHandler.handle(error, title: title) {
                dismiss()
            }
        }
    }

    func migrate(_ allProfiles: [MigratableProfile]) async {
        guard case .fetched = model.step else {
            assertionFailure("Must call fetch() and succeed, why is button enabled?")
            return
        }

        let profiles = allProfiles.filter {
            model.statuses[$0.id] != .excluded
        }
        guard !profiles.isEmpty else {
            assertionFailure("Nothing to migrate, why is button enabled?")
            return
        }

        let previousStep = model.step
        model.step = .migrating
        do {
            pp_log(.App.migration, .notice, "Migrate \(profiles.count) profiles...")
            let profiles = try await migrationManager.migratedProfiles(profiles) {
                guard $1 != .done else {
                    return
                }
                model.statuses[$0] = $1
            }
            pp_log(.App.migration, .notice, "Mapped \(profiles.count) profiles to the new format, saving...")
            await migrationManager.importProfiles(profiles, into: profileManager) {
                model.statuses[$0] = $1
            }
            let migrated = profiles.filter {
                model.statuses[$0.id] == .done
            }
            pp_log(.App.migration, .notice, "Migrated \(migrated.count) profiles")

            // TODO: ### restore auto-deletion after stable 3.0.0, otherwise users could not downgrade
//            if !iapManager.isBeta {
//                do {
//                    try await migrationManager.deleteMigratableProfiles(withIds: Set(migrated.map(\.id)))
//                    pp_log(.App.migration, .notice, "Discarded \(migrated.count) migrated profiles from old store")
//                } catch {
//                    pp_log(.App.migration, .error, "Unable to discard migrated profiles: \(error)")
//                }
//            } else {
                pp_log(.App.migration, .notice, "Restricted build, do not discard migrated profiles")
//            }

            model.step = .migrated(migrated)
        } catch {
            pp_log(.App.migration, .error, "Unable to migrate profiles: \(error)")
            errorHandler.handle(error, title: title)
            model.step = previousStep
        }
    }

    func confirmPendingDeletion() {
        guard let profilesPendingDeletion else {
            isEditing = false
            assertionFailure("No profiles pending deletion?")
            return
        }
        let deletedIds = Set(profilesPendingDeletion.map(\.id))
        Task {
            do {
                try await migrationManager.deleteMigratableProfiles(withIds: deletedIds)
                withAnimation {
                    model.profiles.removeAll {
                        deletedIds.contains($0.id)
                    }
                    model.step = .fetched(model.profiles)
                }
            } catch {
                pp_log(.App.migration, .error, "Unable to delete migratable profiles \(deletedIds): \(error)")
            }
            isEditing = false
        }
    }
}
