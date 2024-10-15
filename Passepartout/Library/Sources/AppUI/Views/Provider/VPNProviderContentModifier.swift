//
//  VPNProviderContentModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/7/24.
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

import AppLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

struct VPNProviderContentModifier<Configuration, ProviderRows>: ViewModifier where Configuration: ProviderConfigurationIdentifiable & Codable, ProviderRows: View {

    @Binding
    var providerId: ProviderID?

    @Binding
    var selectedEntity: VPNEntity<Configuration>?

    let configurationType: Configuration.Type

    let isRequired: Bool

    @ViewBuilder
    let providerRows: ProviderRows

    @StateObject
    private var vpnProviderManager = VPNProviderManager()

    func body(content: Content) -> some View {
        content
            .modifier(ProviderContentModifier(
                providerId: $providerId,
                entityType: VPNEntity<Configuration>.self,
                isRequired: isRequired,
                providerRows: {
                    providerServerRow
                    providerRows
                },
                onSelectProvider: onSelectProvider
            ))
    }
}

private extension VPNProviderContentModifier {
    var providerServerRow: some View {
        NavigationLink {
            VPNProviderServerView<Configuration>(
                manager: vpnProviderManager,
                onSelect: onSelectServer
            )
        } label: {
            HStack {
                Text(Strings.Global.server)
                if let selectedEntity {
                    Spacer()
                    Text(selectedEntity.server.hostname ?? selectedEntity.server.serverId)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    func onSelectProvider(manager: ProviderManager, providerId: ProviderID?, isInitial: Bool) {
        guard let providerId else {
            return
        }
        let initialEntity = isInitial ? selectedEntity : nil
        if !isInitial {
            selectedEntity = nil
        }
        let view = manager.vpnView(
            for: providerId,
            configurationType: OpenVPN.Configuration.self,
            initialParameters: .init(
                sorting: [
                    .localizedCountry,
                    .area,
                    .hostname
                ]
            )
        )
        vpnProviderManager.setView(view, filteringWith: initialEntity?.server.provider)
    }

    func onSelectServer(server: VPNServer, preset: VPNPreset<Configuration>) {
        selectedEntity = VPNEntity(server: server, preset: preset)
    }
}

// MARK: - Preview

#Preview {
    List {
        EmptyView()
            .modifier(VPNProviderContentModifier(
                providerId: .constant(.hideme),
                selectedEntity: .constant(nil),
                configurationType: OpenVPN.Configuration.self,
                isRequired: false,
                providerRows: {
                    Text("Other")
                }
            ))
    }
    .withMockEnvironment()
}
