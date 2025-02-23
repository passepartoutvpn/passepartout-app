//
//  WireGuardView+Configuration.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/28/24.
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

import PassepartoutKit
import SwiftUI

extension WireGuardView {
    struct ConfigurationView: View {

        @Binding
        var configuration: WireGuard.Configuration.Builder

        @State
        private var model = ViewModel()

        var body: some View {
            Group {
                interfaceSection
                dnsSection
                ForEach(Array(zip(model.peersOrder.indices, model.peersOrder)), id: \.1) { index, publicKey in
                    peerSection(for: publicKey, at: index)
                }
                addPeerButton
            }
            .onLoad {
                model.load(from: configuration)
            }
            .onChange(of: model) {
                $0.save(to: &configuration)
            }
        }
    }
}

private extension WireGuardView.ConfigurationView {
    var interfaceSection: some View {
        themeModuleSection(header: Strings.Modules.Wireguard.interface) {
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.privateKey,
                value: $model.privateKey
            )
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.addresses,
                value: $model.addresses
            )
            ThemeModuleTextField(
                caption: Strings.Unlocalized.mtu,
                value: $model.mtu,
                placeholder: Strings.Unlocalized.Placeholders.mtu
            )
        }
    }

    var dnsSection: some View {
        themeModuleSection(header: Strings.Unlocalized.dns) {
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.servers,
                value: $model.dnsServers
            )
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.domain,
                value: $model.dnsDomain
            )
            ThemeModuleLongContent(
                caption: Strings.Entities.Dns.searchDomains,
                value: $model.dnsSearchDomains
            )
        }
    }

    func peerSection(for publicKey: String, at index: Int) -> some View {
        themeModuleSection(header: Strings.Modules.Wireguard.peer(index + 1)) {
            let peerBinding = peerBinding(with: publicKey)

            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.publicKey,
                value: peerBinding.publicKey
            )
            ThemeModuleLongContent(
                caption: Strings.Modules.Wireguard.presharedKey,
                value: peerBinding.preSharedKey
            )
            ThemeModuleLongContent(
                caption: Strings.Global.Nouns.endpoint,
                value: peerBinding.endpoint
            )
            ThemeModuleLongContent(
                caption: Strings.Modules.Wireguard.allowedIps,
                value: peerBinding.allowedIPs
            )
            ThemeModuleTextField(
                caption: Strings.Global.Nouns.keepAlive,
                value: peerBinding.keepAlive,
                placeholder: Strings.Unlocalized.Placeholders.keepAlive
            )
            // FIXME: #1197, l10n
            Button("Delete peer") {
                withAnimation {
                    model.peersOrder.remove(at: index)
                    model.peers.removeValue(forKey: publicKey)
                }
            }
        }
    }

    // FIXME: #1197, l10n
    var addPeerButton: some View {
        Button("Add peer") {
            let newPeer = ViewModel.Peer()
            assert(newPeer.publicKey == "")
            withAnimation {
                model.peers[newPeer.publicKey] = newPeer
                model.peersOrder.append(newPeer.publicKey)
            }
        }
        .disabled(model.peers[""] != nil)
    }
}

private extension WireGuardView.ConfigurationView {
    var dnsRows: [Any?] {
        [
            configuration.interface.dns.servers.nilIfEmpty,
            configuration.interface.dns.domainName,
            configuration.interface.dns.searchDomains?.nilIfEmpty
        ]
    }
}

// MARK: - Logic

private extension WireGuardView.ConfigurationView {
    struct ViewModel: Equatable {
        struct Peer: Equatable {
            var publicKey = ""

            var preSharedKey = ""

            var endpoint = ""

            var allowedIPs = ""

            var keepAlive = ""
        }

        private let separator = ","

        var privateKey = ""

        var addresses = ""

        var mtu = ""

        var dnsServers = ""

        var dnsDomain = ""

        var dnsSearchDomains = ""

        var peers: [String: Peer] = [:]

        var peersOrder: [String] = []

        mutating func load(from configuration: WireGuard.Configuration.Builder) {
            privateKey = configuration.interface.privateKey
            addresses = configuration.interface.addresses.joined(separator: separator)
            mtu = configuration.interface.mtu?.description ?? ""

            dnsServers = configuration.interface.dns.servers.joined(separator: separator)
            dnsDomain = configuration.interface.dns.domainName ?? ""
            dnsSearchDomains = configuration.interface.dns.searchDomains?.joined(separator: separator) ?? ""

            peers = configuration.peers.reduce(into: [:]) {
                var peer = Peer()
                peer.publicKey = $1.publicKey
                peer.preSharedKey = $1.preSharedKey ?? ""
                peer.endpoint = $1.endpoint ?? ""
                peer.allowedIPs = $1.allowedIPs.joined(separator: separator)
                peer.keepAlive = $1.keepAlive?.description ?? ""
                $0[$1.publicKey] = peer
            }
            peersOrder = configuration.peers.map(\.publicKey)
        }

        func save(to configuration: inout WireGuard.Configuration.Builder) {
            configuration.interface.privateKey = privateKey
            configuration.interface.addresses = addresses.trimmedSplit(separator: separator)
            configuration.interface.mtu = UInt16(mtu)

            var dns = DNSModule.Builder()
            dns.servers = dnsServers.trimmedSplit(separator: separator)
            dns.domainName = dnsDomain
            dns.searchDomains = dnsSearchDomains.trimmedSplit(separator: separator)
            configuration.interface.dns = dns

            configuration.peers = peersOrder
                .compactMap {
                    guard let model = peers[$0] else {
                        return nil
                    }
                    var peer = WireGuard.RemoteInterface.Builder(publicKey: model.publicKey)
                    peer.preSharedKey = model.preSharedKey
                    peer.endpoint = model.endpoint
                    peer.allowedIPs = model.allowedIPs.trimmedSplit(separator: separator)
                    peer.keepAlive = UInt16(model.keepAlive)
                    return peer
                }
        }
    }

    func peerBinding(with publicKey: String) -> Binding<ViewModel.Peer> {
        Binding {
            model.peers[publicKey] ?? ViewModel.Peer()
        } set: {
            model.peers[publicKey] = $0
        }
    }
}

// MARK: - Previews

#Preview {
    struct Preview: View {

        @State
        private var configuration: WireGuard.Configuration.Builder = .forPreviews

        var body: some View {
            NavigationStack {
                Form {
                    WireGuardView.ConfigurationView(
                        configuration: $configuration
                    )
                }
                .themeForm()
                .withMockEnvironment()
            }
        }
    }

    return Preview()
}
