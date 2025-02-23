//
//  WireGuard+Previews.swift
//  Passepartout
//
//  Created by Davide De Rosa on 1/30/25.
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

import Foundation
import PassepartoutKit

// swiftlint: disable force_try
extension WireGuard.Configuration.Builder {
    static var forPreviews: Self {
        let gen = MockGenerator()

        var builder = WireGuard.Configuration.Builder(keyGenerator: gen)
        builder.interface.addresses = ["1.1.1.1", "2.2.2.2"]
        builder.interface.mtu = 1200
        builder.interface.dns.protocolType = .cleartext
        builder.interface.dns.servers = ["8.8.8.8", "4.4.4.4"]
        builder.interface.dns.domainName = "domain.com"
        builder.interface.dns.searchDomains = ["search1.com", "search2.net"]

        builder.peers = (0..<3).map { _ in
            var peer = WireGuard.RemoteInterface.Builder(publicKey: try! gen.publicKey(for: gen.newPrivateKey()))
            peer.preSharedKey = gen.newPrivateKey()
            peer.allowedIPs = ["1.1.1.1/8", "2.2.2.2/12"]
            peer.endpoint = "8.8.8.8:12345"
            peer.keepAlive = 30
            return peer
        }
        return builder
    }
}
// swiftlint: enable force_try

private final class MockGenerator: WireGuardKeyGenerator {
    func newPrivateKey() -> String {
        "private-key-\(randomNumber)"
    }

    func privateKey(from string: String) throws -> String {
        "private-key-\(randomNumber)"
    }

    func publicKey(from string: String) throws -> String {
        "public-key-\(randomNumber)"
    }

    func publicKey(for privateKey: String) throws -> String {
        "public-key-\(randomNumber)"
    }

    private var randomNumber: Int {
        Int.random(in: 0..<1000)
    }
}
