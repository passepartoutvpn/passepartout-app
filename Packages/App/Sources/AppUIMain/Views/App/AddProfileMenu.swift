//
//  AddProfileMenu.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/3/24.
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
import PassepartoutKit
import SwiftUI

struct AddProfileMenu: View {
    let profileManager: ProfileManager

    let registry: Registry

    @Binding
    var isImporting: Bool

    let onMigrateProfiles: () -> Void

    let onNewProfile: (EditableProfile, UUID?) -> Void

    var body: some View {
        Menu {
            emptyProfileButton
            importProfileButton
            Divider()
            providerProfileMenu
            Divider()
            migrateProfilesButton
        } label: {
            ThemeImage(.add)
        }
    }
}

private extension AddProfileMenu {
    var emptyProfileButton: some View {
        Button {
            let editable = EditableProfile(name: newName)
            onNewProfile(editable, nil)
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.NewProfile.empty, .profileEdit)
        }
    }

    var importProfileButton: some View {
        Button {
            isImporting = true
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.importProfile.forMenu, .profileImport)
        }
    }

    var providerProfileMenu: some View {
        Menu {
            ForEach(supportedProviderModuleTypes, content: providerSubmenu(for:))
        } label: {
            ThemeImageLabel(Strings.Views.App.Toolbar.NewProfile.provider, .profileProvider)
        }
    }

    func providerSubmenu(for moduleType: ModuleType) -> some View {
        ProvidersSubmenu(
            moduleType: moduleType,
            registry: registry,
            onSelect: {
                var copy = $0
                copy.name = profileManager.firstUniqueName(from: copy.name)
                onNewProfile(copy, copy.modules.first?.id)
            }
        )
    }

    var migrateProfilesButton: some View {
        Button(action: onMigrateProfiles) {
            ThemeImageLabel(Strings.Views.App.Toolbar.migrateProfiles.forMenu, .profileMigrate)
        }
    }
}

private extension AddProfileMenu {
    var newName: String {
        profileManager.firstUniqueName(from: Strings.Placeholders.Profile.name)
    }

    // TODO: #507, define this list in a single global place
    var supportedProviderModuleTypes: [ModuleType] {
        [.openVPN]
    }
}

// MARK: - Providers

private struct ProvidersSubmenu: View {

    @EnvironmentObject
    private var apiManager: APIManager

    let moduleType: ModuleType

    let registry: Registry

    let onSelect: (EditableProfile) -> Void

    var body: some View {
        Menu {
            ForEach(apiManager.providers, content: profileButton(for:))
        } label: {
            Text(moduleType.localizedDescription)
        }
    }

    func profileButton(for provider: Provider) -> some View {
        Button(provider.description) {
            var editable = EditableProfile()
            editable.name = provider.description
            let newModule = moduleType.newModule(with: registry, providerId: provider.id)
            if let providerBuilder = newModule as? any ProviderSelecting {
                assert(providerBuilder.providerId == provider.id)
            }
            editable.modules.append(newModule)
            var onDemandBuilder = OnDemandModule.Builder()
            onDemandBuilder.isEnabled = true
            editable.modules.append(onDemandBuilder)
            editable.activeModulesIds = Set(editable.modules.map(\.id))
            onSelect(editable)
        }
    }
}
