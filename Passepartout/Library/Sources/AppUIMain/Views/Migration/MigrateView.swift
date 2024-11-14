//
//  MigrateView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/13/24.
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

import CommonLibrary
import CommonUtils
import PassepartoutKit
import SwiftUI

// FIXME: ###, migrations UI

struct MigrateView: View {
    enum Style {
        case section

        case table
    }

    @EnvironmentObject
    private var migrationManager: MigrationManager

    let style: Style

    @ObservedObject
    var profileManager: ProfileManager

    @State
    private var model = Model()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    var body: some View {
        Form {
            ContentView(
                style: style,
                step: model.step,
                profiles: model.profiles,
                excluded: $model.excluded,
                statuses: model.statuses
            )
            .disabled(model.step != .fetched)
        }
        .themeForm()
        .themeProgress(if: model.step == .fetching)
        .themeEmptyContent(if: model.step == .fetched && model.profiles.isEmpty, message: "Nothing to migrate")
        .themeAnimation(on: model.step, category: .profiles)
        .navigationTitle(title)
        .toolbar(content: toolbarContent)
        .task {
            await fetch()
        }
        .withErrorHandler(errorHandler)
    }
}

private extension MigrateView {
    var title: String {
        Strings.Views.Migrate.title
    }

    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button(performTitle(at: model.step).title) {
                Task {
                    await performAction(at: model.step)
                }
            }
            .disabled(!performTitle(at: model.step).enabled)
        }
    }
}

private extension MigrateView {
    func performTitle(at step: Model.Step) -> (title: String, enabled: Bool) {
        switch step {
        case .initial, .fetching:
            return ("Proceed", false)

        case .fetched:
            return ("Proceed", true)

        case .migrating:
            return ("Import", false)

        case .migrated(let profiles):
            return ("Import", !profiles.isEmpty)

        case .imported:
            return ("Done", true)
        }
    }

    func performAction(at step: Model.Step) async {
        switch step {
        case .fetched:
            await migrate()

        case .migrated(let profiles):
            await save(profiles)

        default:
            fatalError("No action allowed at this step \(step)")
        }
    }

    func fetch() async {
        guard model.step == .initial else {
            return
        }
        do {
            model.step = .fetching
            let migratable = try await migrationManager.fetchMigratableProfiles()
            let knownIDs = Set(profileManager.headers.map(\.id))
            model.profiles = migratable.filter {
                !knownIDs.contains($0.id)
            }
            model.step = .fetched
        } catch {
            pp_log(.App.migration, .error, "Unable to fetch migratable profiles: \(error)")
            errorHandler.handle(error, title: title)
            model.step = .initial
        }
    }

    func migrate() async {
        guard model.step == .fetched else {
            fatalError("Must call fetch() and succeed first")
        }
        do {
            model.step = .migrating
            let profiles = try await migrationManager.migrateProfiles(model.profiles, selection: model.selection) {
                model.statuses[$0] = $1
            }
            model.step = .migrated(profiles)
        } catch {
            pp_log(.App.migration, .error, "Unable to migrate profiles: \(error)")
            errorHandler.handle(error, title: title)
        }
    }

    func save(_ profiles: [Profile]) async {
        // FIXME: ###, import migrated profiles
    }
}
