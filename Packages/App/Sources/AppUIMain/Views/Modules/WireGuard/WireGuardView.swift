//
//  WireGuardView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/31/24.
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

struct WireGuardView: View, ModuleDraftEditing {

    @Environment(\.navigationPath)
    private var path

    let module: WireGuardModule.Builder

    @ObservedObject
    var editor: ProfileEditor

    let impl: WireGuardModule.Implementation?

    @State
    private var paywallReason: PaywallReason?

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    init(module: WireGuardModule.Builder, parameters: ModuleViewParameters) {
        self.module = module
        editor = parameters.editor
        impl = parameters.impl as? WireGuardModule.Implementation
    }

    var body: some View {
        contentView
            .moduleView(editor: editor, draft: draft.wrappedValue)
            .themeAnimation(on: draft.wrappedValue.providerId, category: .modules)
            .modifier(PaywallModifier(reason: $paywallReason))
            .withErrorHandler(errorHandler)
    }
}

// MARK: - Content

private extension WireGuardView {

    @ViewBuilder
    var contentView: some View {
        if let configurationBinding {
            ConfigurationView(configuration: configurationBinding)
        } else {
            EmptyView()
                .modifier(providerModifier)
        }
    }

    var providerModifier: some ViewModifier {
        ProviderContentModifier(
            providerId: providerId,
            providerPreferences: nil,
            selectedEntity: providerEntity,
            entityDestination: ProfileRoute(Subroute.providerServer),
            paywallReason: $paywallReason,
            providerRows: providerRows
        )
    }

    func providerRows() -> some View {
        ThemeModulePush(caption: Strings.Modules.Wireguard.providerKey, route: ProfileRoute(Subroute.providerKey))
    }
}

private extension WireGuardView {
    func onSelectServer(server: ProviderServer, preset: ProviderPreset<WireGuardProviderTemplate>) {
        draft.wrappedValue.providerEntity = ProviderEntity(server: server, preset: preset)
        path.wrappedValue.removeLast()
    }

    func importConfiguration(from url: URL) {
        // TODO: #397, import draft from external URL
    }

    func editConfiguration() {
        // TODO: #397, edit configuration as text
    }
}

// MARK: - Destinations

private extension WireGuardView {
    enum Subroute: Hashable {
        case providerServer

        case providerKey
    }

    @ViewBuilder
    func destination(for route: Subroute) -> some View {
        switch route {
        case .providerServer:
            draft.wrappedValue.providerSelection.map {
                ProviderServerView(
                    moduleId: module.id,
                    providerId: $0.id,
                    selectedEntity: $0.entity,
                    filtersWithSelection: true,
                    onSelect: onSelectServer
                )
            }

        case .providerKey:
            // TODO: #339, WireGuard upload public key to provider
            EmptyView()
        }
    }
}

// MARK: - Logic

private extension WireGuardView {
    var configurationBinding: Binding<WireGuard.Configuration.Builder>? {
        guard draft.wrappedValue.configurationBuilder != nil else {
            return nil
        }
        return Binding {
            draft.wrappedValue.configurationBuilder ?? impl.map {
                .init(keyGenerator: $0.keyGenerator)
            } ?? .init(privateKey: "")
        } set: {
            draft.wrappedValue.configurationBuilder = $0
        }
    }
}

// MARK: - Previews

#Preview {
    let module = WireGuardModule.Builder(configurationBuilder: .forPreviews)
    return module.preview()
}
