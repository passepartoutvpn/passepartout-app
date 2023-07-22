//
//  EndpointView+OpenVPN.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/19/22.
//  Copyright (c) 2023 Davide De Rosa. All rights reserved.
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

import PassepartoutLibrary
import SwiftUI
import TunnelKitOpenVPN

extension EndpointView {
    struct OpenVPNView: View {
        @ObservedObject private var providerManager: ProviderManager

        @ObservedObject private var currentProfile: ObservableProfile

        @Binding private var builder: OpenVPN.ConfigurationBuilder

        @State private var isFirstAppearance = true

        @State private var isAutomatic = false

        @State private var isExpanded: [String: Bool] = [:]

        init(currentProfile: ObservableProfile) {
            let providerManager: ProviderManager = .shared

            self.providerManager = providerManager
            self.currentProfile = currentProfile

            _builder = currentProfile.builderBinding(providerManager: providerManager)
        }

        var body: some View {
            ScrollViewReader { scrollProxy in
                List {
                    mainSection
                    endpointsSections
                    advancedSection
                }.onAppear {
                    isAutomatic = (currentProfile.value.customEndpoint == nil)
                    if let customEndpoint = currentProfile.value.customEndpoint {
                        isExpanded[customEndpoint.address] = true
                    }
                    scrollToCustomEndpoint(scrollProxy)
                }.onChange(of: isAutomatic, perform: onToggleAutomatic)
            }.navigationTitle(L10n.Global.Strings.endpoint)
        }
    }
}

// MARK: -

private extension EndpointView.OpenVPNView {
    var mainSection: some View {
        Section {
            Toggle(L10n.Global.Strings.automatic, isOn: $isAutomatic.themeAnimation())
        } footer: {
            // FIXME: l10n
            themeErrorMessage(isManualEndpointRequired ? L10n.Endpoint.Errors.endpointRequired : nil)
        }
    }

    var endpointsSections: some View {
        ForEach(endpointsByAddress, content: endpointsGroup(forSection:))
            .disabled(isAutomatic)
    }

    // TODO: OpenVPN, make endpoints editable
    func endpointsGroup(forSection section: EndpointsByAddress) -> some View {
        Section {
            DisclosureGroup(isExpanded: isExpandedBinding(address: section.address)) {
                ForEach(section.endpoints) {
                    row(forEndpoint: $0)
                }
            } label: {
                Text(L10n.Global.Strings.address)
                    .withTrailingText(section.address)
            }
        }
    }

    func row(forEndpoint endpoint: Endpoint) -> some View {
        Button {
            withAnimation {
                currentProfile.value.customEndpoint = endpoint
            }
        } label: {
            Text(endpoint.proto.rawValue)
        }.withTrailingCheckmark(when: currentProfile.value.customEndpoint == endpoint)
    }

    var advancedSection: some View {
        Section {
            let caption = L10n.Endpoint.Advanced.title
            NavigationLink(caption) {
                EndpointAdvancedView.OpenVPNView(
                    builder: $builder,
                    isReadonly: isConfigurationReadonly,
                    isServerPushed: false
                ).navigationTitle(caption)
            }
        }
    }

    var endpointsByAddress: [EndpointsByAddress] {
        guard let remotes = builder.remotes, !remotes.isEmpty else {
            return []
        }
        var uniqueAddresses: [String] = []
        remotes.forEach {
            guard !uniqueAddresses.contains($0.address) else {
                return
            }
            uniqueAddresses.append($0.address)
        }
        return uniqueAddresses.map {
            EndpointsByAddress(address: $0, remotes: remotes)
        }
    }

    var isManualEndpointRequired: Bool {
        !isAutomatic && currentProfile.value.customEndpoint == nil
    }

    var isConfigurationReadonly: Bool {
        currentProfile.value.isProvider
    }
}

private struct EndpointsByAddress: Identifiable {
    let address: String

    let endpoints: [Endpoint]

    init(address: String, remotes: [Endpoint]?) {
        self.address = address
        endpoints = remotes?.filter {
            $0.address == address
        }.sorted() ?? []
    }

    // MARK: Identifiable

    var id: String {
        address
    }
}

// MARK: -

private extension EndpointView.OpenVPNView {
    func onToggleAutomatic(_ value: Bool) {
        guard value else {
            return
        }
        guard currentProfile.value.customEndpoint != nil else {
            return
        }
        withAnimation {
            currentProfile.value.customEndpoint = nil
            isExpanded.removeAll()
        }
    }

    func scrollToCustomEndpoint(_ proxy: ScrollViewProxy) {
        proxy.maybeScrollTo(currentProfile.value.customEndpoint?.id)
    }
}

// MARK: - Bindings

private extension ObservableProfile {
    func builderBinding(providerManager: ProviderManager) -> Binding<OpenVPN.ConfigurationBuilder> {
        .init {
            if self.value.isProvider {
                guard let server = self.value.providerServer(providerManager) else {
                    assertionFailure("Server not found")
                    return .init()
                }
                guard let preset = self.value.providerPreset(server) else {
                    assertionFailure("Preset not found")
                    return .init()
                }
                guard let cfg = preset.openVPNConfiguration else {
                    assertionFailure("Preset \(preset.id) (\(preset.name)) has no OpenVPN configuration")
                    return .init()
                }
                var builder = cfg.builder(withFallbacks: true)
                try? builder.setRemotes(from: preset, with: server, excludingHostname: false)
                return builder
            } else if let cfg = self.value.hostOpenVPNSettings?.configuration {
                let builder = cfg.builder(withFallbacks: true)
//                pp_log.debug("Loading OpenVPN configuration: \(builder)")
                return builder
            }
            // fall back gracefully
            return .init()
        } set: {
            if self.value.isProvider {
                // readonly
            } else {
                pp_log.debug("Saving OpenVPN configuration: \($0)")
                self.value.hostOpenVPNSettings?.configuration = $0.build()
            }
        }
    }
}

private extension EndpointView.OpenVPNView {
    func isExpandedBinding(address: String) -> Binding<Bool> {
        .init {
            isExpanded[address] ?? false
        } set: {
            isExpanded[address] = $0
        }
    }
}

private extension Profile {
    var customEndpoint: Endpoint? {
        get {
            if isProvider {
                return providerCustomEndpoint
            } else {
                return hostOpenVPNSettings?.customEndpoint
            }
        }
        set {
            if isProvider {
                providerCustomEndpoint = newValue
            } else {
                hostOpenVPNSettings?.customEndpoint = newValue
            }
        }
    }
}
