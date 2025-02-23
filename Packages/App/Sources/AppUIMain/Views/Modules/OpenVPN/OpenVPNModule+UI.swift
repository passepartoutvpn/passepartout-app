//
//  OpenVPNModule+UI.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/12/25.
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

extension OpenVPNModule.Builder: ModuleViewProviding {
    public func moduleView(with parameters: ModuleViewParameters) -> some View {
        OpenVPNView(module: self, parameters: parameters)
    }
}

extension OpenVPNModule: ProviderServerCoordinatorSupporting {
}

// MARK: - Destination

extension OpenVPNModule {
    enum Subroute: Hashable {
        case providerServer

        case providerConfiguration(OpenVPN.Configuration)

        case credentials

        case remotes
    }
}

extension OpenVPNModule.Builder: ModuleDestinationProviding {
    public func handlesRoute(_ route: AnyHashable) -> Bool {
        route is OpenVPNModule.Subroute
    }

    public func moduleDestination(
        for route: AnyHashable,
        with parameters: ModuleDestinationParameters,
        path: Binding<NavigationPath>
    ) -> some View {
        (route as? OpenVPNModule.Subroute)
            .map {
                DestinationView(route: $0, parameters: parameters, path: path)
            }
    }
}

private struct DestinationView: View {
    let route: OpenVPNModule.Subroute

    let parameters: ModuleDestinationParameters

    @Binding
    var path: NavigationPath

    @State
    private var preferences = ModulePreferences()

    var body: some View {
        Group {
            switch route {
            case .providerServer:
                draft.wrappedValue.providerSelection.map {
                    ProviderServerView(
                        moduleId: parameters.module.id,
                        providerId: $0.id,
                        selectedEntity: $0.entity,
                        filtersWithSelection: true,
                        onSelect: onSelectServer
                    )
                }

            case .providerConfiguration(let configuration):
                Form {
                    OpenVPNView.ConfigurationView(
                        isServerPushed: false,
                        configuration: .constant(configuration.builder()),
                        credentialsRoute: nil
                    )
                }
                .themeForm()
                .navigationTitle(Strings.Global.Nouns.configuration)

            case .credentials:
                Form {
                    OpenVPNCredentialsView(
                        profileEditor: parameters.editor,
                        providerId: draft.wrappedValue.providerId,
                        isInteractive: draft.isInteractive,
                        credentials: draft.credentials
                    )
                }
                .navigationTitle(Strings.Modules.Openvpn.credentials)
                .themeForm()
                .themeAnimation(on: draft.wrappedValue.isInteractive, category: .modules)

            case .remotes:
                OpenVPNView.RemotesView(
                    configurationBuilder: configurationBuilderBinding,
                    excludedEndpoints: excludedEndpoints,
                    isEditable: draft.wrappedValue.providerSelection == nil
                )
            }
        }
        .modifier(ModulePreferencesModifier(
            moduleId: parameters.module.id,
            preferences: preferences
        ))
    }
}

private extension DestinationView {
    var draft: Binding<OpenVPNModule.Builder> {
        guard let builder = parameters.module as? OpenVPNModule.Builder else {
            fatalError("Not a OpenVPNModule.Builder")
        }
        return parameters.editor[builder]
    }

    var configurationBuilderBinding: Binding<OpenVPN.Configuration.Builder> {
        if let providerConfiguration = try? draft.wrappedValue.providerSelection?.configuration().builder() {
            return .constant(providerConfiguration)
        }
        return Binding {
            draft.wrappedValue.configurationBuilder ?? OpenVPN.Configuration.Builder()
        } set: {
            draft.wrappedValue.configurationBuilder = $0
        }
    }

    var excludedEndpoints: ObservableList<ExtendedEndpoint> {
        parameters.editor.excludedEndpoints(for: parameters.module.id, preferences: preferences)
    }

    func onSelectServer(server: ProviderServer, preset: ProviderPreset<OpenVPNProviderTemplate>) {
        draft.wrappedValue.providerEntity = ProviderEntity(server: server, preset: preset)
        resetExcludedEndpointsWithCurrentProviderEntity()
        path.removeLast()
    }

    // filter out exclusions unrelated to current server
    func resetExcludedEndpointsWithCurrentProviderEntity() {
        do {
            let cfg = try draft.wrappedValue.providerSelection?.configuration()
            parameters.editor.profile.attributes.editPreferences(inModule: parameters.module.id) {
                if let cfg {
                    $0.excludedEndpoints = Set(cfg.remotes?.filter {
                        preferences.isExcludedEndpoint($0)
                    } ?? [])
                } else {
                    $0.excludedEndpoints = []
                }
            }
        } catch {
            pp_log(.app, .error, "Unable to build provider configuration for excluded endpoints: \(error)")
        }
    }
}

// MARK: - Shortcuts

extension OpenVPNModule.Builder: ModuleShortcutsProviding {
    public var isVisible: Bool {
        providerSelection != nil || configurationBuilder?.authUserPass == true
    }

    @ViewBuilder
    public func moduleShortcutsView(editor: ProfileEditor, path: Binding<NavigationPath>) -> some View {
        if let providerSelection {
//            ProviderNameRow(id: providerSelection.id)
            NavigationLink(value: ProfileRoute(OpenVPNModule.Subroute.providerServer)) {
                ProviderServerRow(selectedEntity: providerSelection.entity)
            }
            .uiAccessibility(.Profile.providerServerLink)
        }
        if providerSelection != nil || configurationBuilder?.authUserPass == true {
            NavigationLink(value: ProfileRoute(OpenVPNModule.Subroute.credentials)) {
                Text(Strings.Modules.Openvpn.credentials)
            }
        }
    }
}
