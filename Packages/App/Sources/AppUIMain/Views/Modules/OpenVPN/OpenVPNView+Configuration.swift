//
//  OpenVPNView+Configuration.swift
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

import CommonLibrary
import PassepartoutKit
import SwiftUI

extension OpenVPNView {
    struct ConfigurationView: View {
        let isServerPushed: Bool

        @Binding
        var configuration: OpenVPN.Configuration.Builder

        let credentialsRoute: (any Hashable)?

        var body: some View {
            accountSection
            if !isServerPushed {
                pullSection
            }
            redirectSection
            ipv4Section
            ipv6Section
            dnsSection
            proxySection
            communicationSection
            compressionSection
            if !isServerPushed {
                tlsSection
            }
            keepAliveSection
            otherSection
        }
    }
}

// MARK: - Constant

private extension OpenVPNView.ConfigurationView {
    var accountSection: some View {
        credentialsRoute.map { route in
            themeModuleSection(if: accountRows, header: Strings.Global.Nouns.account) {
                ThemeModulePush(
                    caption: Strings.Modules.Openvpn.credentials,
                    route: route
                )
            }
        }
    }

    var pullSection: some View {
        configuration.pullMask
            .map { mask in
                themeModuleSection(if: pullRows, header: Strings.Modules.Openvpn.pull) {
                    ForEach(mask.map(\.localizedDescription).sorted(), id: \.self) {
                        ThemeModuleText(caption: $0, value: nil)
                    }
                }
            }
    }

    var redirectSection: some View {
        configuration.routingPolicies
            .map { policies in
                themeModuleSection(if: redirectRows, header: Strings.Modules.Openvpn.redirectGateway) {
                    let sortedPolicies = policies.compactMap {
                        switch $0 {
                        case .IPv4: return Strings.Unlocalized.ipv4
                        case .IPv6: return Strings.Unlocalized.ipv6
                        default: return nil
                        }
                    }
                    .sorted()

                    ForEach(sortedPolicies, id: \.self) {
                        ThemeModuleText(caption: $0)
                    }
                }
            }
    }

    var ipv4Section: some View {
        themeModuleSection(
            if: ipRows(for: configuration.ipv4, routes: configuration.routes4),
            header: Strings.Unlocalized.ipv4
        ) {
            ipSection(for: configuration.ipv4, routes: configuration.routes4)
        }
    }

    var ipv6Section: some View {
        themeModuleSection(
            if: ipRows(for: configuration.ipv6, routes: configuration.routes6),
            header: Strings.Unlocalized.ipv6
        ) {
            ipSection(for: configuration.ipv6, routes: configuration.routes6)
        }
    }

    @ViewBuilder
    func ipSection(for ip: IPSettings?, routes: [Route]?) -> some View {
        if let ip {
            ip.localizedDescription(optionalStyle: .address).map {
                ThemeModuleCopiableText(caption: Strings.Global.Nouns.address, value: $0)
            }
            ip.localizedDescription(optionalStyle: .defaultGateway).map {
                ThemeModuleCopiableText(caption: Strings.Global.Nouns.gateway, value: $0)
            }

            ip.includedRoutes
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Modules.Ip.Routes.included,
                        values: $0.map(\.localizedDescription)
                    )
                }

            ip.excludedRoutes
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Modules.Ip.Routes.excluded,
                        values: $0.map(\.localizedDescription)
                    )
                }
        }
        routes.map { routes in
            ForEach(routes, id: \.self) {
                ThemeModuleLongContent(
                    caption: Strings.Global.Nouns.route,
                    value: .constant($0.localizedDescription)
                )
            }
        }
    }

    var dnsSection: some View {
        themeModuleSection(if: dnsRows, header: Strings.Unlocalized.dns) {
            configuration.dnsServers?
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Global.Nouns.servers,
                        values: $0
                    )
                }

            configuration.dnsDomain.map {
                ThemeModuleCopiableText(
                    caption: Strings.Global.Nouns.domain,
                    value: $0
                )
            }

            configuration.searchDomains?
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Entities.Dns.searchDomains,
                        values: $0
                    )
                }
        }
    }

    var proxySection: some View {
        themeModuleSection(if: proxyRows, header: Strings.Unlocalized.proxy) {
            configuration.httpProxy
                .map {
                    ThemeModuleCopiableText(
                        caption: Strings.Unlocalized.http,
                        value: $0.rawValue
                    )
                }

            configuration.httpsProxy
                .map {
                    ThemeModuleCopiableText(
                        caption: Strings.Unlocalized.https,
                        value: $0.rawValue
                    )
                }

            configuration.proxyAutoConfigurationURL
                .map {
                    ThemeModuleCopiableText(
                        caption: Strings.Unlocalized.pac,
                        value: $0.absoluteString
                    )
                }

            configuration.proxyBypassDomains?
                .nilIfEmpty
                .map {
                    ThemeModuleTextList(
                        caption: Strings.Entities.HttpProxy.bypassDomains,
                        values: $0
                    )
                }
        }
    }

    var communicationSection: some View {
        themeModuleSection(if: communicationRows, header: Strings.Modules.Openvpn.communication) {
            configuration.cipher
                .map {
                    ThemeModuleText(caption: Strings.Modules.Openvpn.cipher, value: $0.localizedDescription)
                }

            configuration.digest
                .map {
                    ThemeModuleText(caption: Strings.Modules.Openvpn.digest, value: $0.localizedDescription)
                }

            configuration.xorMethod
                .map {
                    ThemeModuleLongContentPreview(
                        caption: Strings.Unlocalized.xor,
                        value: .constant($0.localizedDescription(style: .long)),
                        preview: $0.localizedDescription(style: .short)
                    )
                }
        }
    }

    var compressionSection: some View {
        themeModuleSection(if: compressionRows, header: Strings.Modules.Openvpn.compression) {
            configuration.compressionFraming
                .map {
                    ThemeModuleText(
                        caption: Strings.Modules.Openvpn.compressionFraming,
                        value: $0.localizedDescription
                    )
                }

            configuration.compressionAlgorithm
                .map {
                    ThemeModuleText(
                        caption: Strings.Modules.Openvpn.compressionAlgorithm,
                        value: $0.localizedDescription
                    )
                }
        }
    }

    var tlsSection: some View {
        themeModuleSection(if: tlsRows, header: Strings.Unlocalized.tls) {
            configuration.ca
                .map {
                    ThemeModuleLongContentPreview(
                        caption: Strings.Unlocalized.ca,
                        value: .constant($0.pem),
                        preview: nil
                    )
                }

            configuration.clientCertificate
                .map {
                    ThemeModuleLongContentPreview(
                        caption: Strings.Global.Nouns.certificate,
                        value: .constant($0.pem),
                        preview: nil
                    )
                }

            configuration.clientKey
                .map {
                    ThemeModuleLongContentPreview(
                        caption: Strings.Global.Nouns.key,
                        value: .constant($0.pem),
                        preview: nil
                    )
                }

            configuration.tlsWrap
                .map {
                    ThemeModuleLongContentPreview(
                        caption: Strings.Modules.Openvpn.tlsWrap,
                        value: .constant($0.key.hexString),
                        preview: configuration.localizedDescription(style: .tlsWrap)
                    )
                }

            ThemeModuleText(
                caption: Strings.Modules.Openvpn.eku,
                value: configuration.localizedDescription(style: .eku)
            )
        }
    }

    var keepAliveSection: some View {
        themeModuleSection(if: keepAliveRows, header: Strings.Global.Nouns.keepAlive) {
            configuration.localizedDescription(optionalStyle: .keepAlive)
                .map {
                    ThemeModuleText(caption: Strings.Global.Nouns.interval, value: $0)
                }

            configuration.localizedDescription(optionalStyle: .keepAliveTimeout)
                .map {
                    ThemeModuleText(caption: Strings.Global.Nouns.timeout, value: $0)
                }
        }
    }

    var otherSection: some View {
        themeModuleSection(if: otherRows, header: Strings.Global.Nouns.other) {
            configuration.localizedDescription(optionalStyle: .renegotiatesAfter)
                .map {
                    ThemeModuleText(caption: Strings.Modules.Openvpn.renegotiation, value: $0)
                }

            configuration.localizedDescription(optionalStyle: .randomizeEndpoint)
                .map {
                    ThemeModuleText(caption: Strings.Modules.Openvpn.randomizeEndpoint, value: $0)
                }

            configuration.localizedDescription(optionalStyle: .randomizeHostnames)
                .map {
                    ThemeModuleText(caption: Strings.Modules.Openvpn.randomizeHostname, value: $0)
                }
        }
    }
}

private extension OpenVPNView.ConfigurationView {
    var accountRows: [Any?] {
        guard credentialsRoute != nil else {
            return []
        }
        guard configuration.authUserPass == true else {
            return []
        }
        return [
            configuration.authUserPass == true ? configuration.authUserPass : nil
        ]
    }

    var pullRows: [Any?] {
        [
            configuration.pullMask?.nilIfEmpty
        ]
    }

    var redirectRows: [Any?] {
        [
            configuration.routingPolicies?.nilIfEmpty
        ]
    }

    func ipRows(for ip: IPSettings?, routes: [Route]?) -> [Any?] {
        guard let ip else {
            return []
        }
        return [
            ip.subnet,
            ip.localizedDescription(optionalStyle: .defaultGateway),
            ip.includedRoutes.nilIfEmpty,
            ip.excludedRoutes.nilIfEmpty
        ]
    }

    var dnsRows: [Any?] {
        [
            configuration.dnsServers?.nilIfEmpty,
            configuration.dnsDomain,
            configuration.searchDomains?.nilIfEmpty
        ]
    }

    var proxyRows: [Any?] {
        [
            configuration.httpProxy,
            configuration.httpsProxy,
            configuration.proxyAutoConfigurationURL,
            configuration.proxyBypassDomains?.nilIfEmpty
        ]
    }

    var communicationRows: [Any?] {
        [
            configuration.cipher,
            configuration.digest,
            configuration.xorMethod
        ]
    }

    var compressionRows: [Any?] {
        [
            configuration.compressionFraming,
            configuration.compressionAlgorithm
        ]
    }

    var tlsRows: [Any?] {
        [
            configuration.ca,
            configuration.clientCertificate,
            configuration.clientKey,
            configuration.tlsWrap
        ]
    }

    var keepAliveRows: [Any?] {
        [
            configuration.keepAliveTimeout,
            configuration.keepAliveInterval
        ]
    }

    var otherRows: [Any?] {
        [
            configuration.renegotiatesAfter,
            configuration.randomizeEndpoint,
            configuration.randomizeHostnames
        ]
    }
}

// MARK: - Previews

#Preview {
    Form {
        OpenVPNView.ConfigurationView(
            isServerPushed: false,
            configuration: .constant(.forPreviews),
            credentialsRoute: nil
        )
    }
    .themeForm()
    .withMockEnvironment()
}
