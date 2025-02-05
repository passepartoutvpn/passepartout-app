//
//  DefaultTunnelProcessor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/8/24.
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
import Foundation
import PassepartoutKit

final class DefaultTunnelProcessor: Sendable {
    init() {
    }
}

extension DefaultTunnelProcessor: PacketTunnelProcessor {
    func willProcess(_ profile: Profile) throws -> Profile {
        do {
            var builder = profile.builder()
            try builder.modules.forEach {
                guard var moduleBuilder = $0.moduleBuilder() as? OpenVPNModule.Builder else {
                    return
                }

                let preferences = builder.attributes.preferences(inModule: moduleBuilder.id)
                moduleBuilder.configurationBuilder?.remotes?.removeAll {
                    preferences.isExcludedEndpoint($0)
                }

                let module = try moduleBuilder.tryBuild()
                builder.saveModule(module)
            }
            return try builder.tryBuild()
        } catch {
            pp_log(.app, .error, "Unable to process profile, revert to original: \(error)")
            return profile
        }
    }
}
