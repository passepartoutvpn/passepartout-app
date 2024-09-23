//
//  Shared.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/25/24.
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

import CPassepartoutOpenVPNOpenSSL
import Foundation
import PassepartoutKit
import PassepartoutWireGuardGo

extension Registry {
    static let shared = Registry(
        withKnownHandlers: true,
        allImplementations: [
            OpenVPNModule.Implementation(
                prng: SecureRandom(),
                dns: CFDNSResolver(),
                importer: StandardOpenVPNParser(decrypter: OSSLTLSBox()),
                sessionBlock: { _, module in
                    try OpenVPNSession(
                        configuration: module.configuration,
                        credentials: module.credentials,
                        prng: SecureRandom(),
                        tlsFactory: {
                            OSSLTLSBox()
                        },
                        cryptoFactory: {
                            OSSLCryptoBox()
                        },
                        cachesURL: FileManager.default.temporaryDirectory
                    )
                }
            ),
            WireGuardModule.Implementation(
                importer: StandardWireGuardParser(),
                connectionBlock: { parameters, module in
                    try GoWireGuardConnection(parameters: parameters, module: module)
                }
            )
        ]
    )
}

extension TunnelEnvironment where Self == AppGroupEnvironment {
    static var shared: Self {
        AppGroupEnvironment(
            appGroup: BundleConfiguration.main.string(for: .groupId),
            prefix: "PassepartoutKit."
        )
    }
}

extension NEProtocolEncoder where Self == KeychainNEProtocolCoder {
    static var shared: Self {
        sharedProtocolCoder
    }
}

extension NEProtocolDecoder where Self == KeychainNEProtocolCoder {
    static var shared: Self {
        sharedProtocolCoder
    }
}

private var sharedProtocolCoder: KeychainNEProtocolCoder {
    KeychainNEProtocolCoder(
        tunnelBundleIdentifier: BundleConfiguration.main.string(for: .tunnelId),
        registry: .shared,
        coder: CodableProfileCoder(),
        keychain: AppleKeychain(group: BundleConfiguration.main.string(for: .keychainGroupId))
    )
}
