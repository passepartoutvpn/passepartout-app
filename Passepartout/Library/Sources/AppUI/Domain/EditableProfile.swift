//
//  EditableProfile.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/6/24.
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

import Foundation
import PassepartoutKit

struct EditableProfile: MutableProfileType {
    var id = UUID()

    var name: String = ""

    var modules: [any ModuleBuilder] = []

    var activeModulesIds: Set<UUID> = []

    var modulesMetadata: [UUID: ModuleMetadata]?

    func builder() -> Profile.Builder {
        fatalError()
    }
}

extension Profile {
    var editableProfile: EditableProfile {
        EditableProfile(
            id: id,
            name: name,
            modules: modulesBuilders,
            activeModulesIds: activeModulesIds,
            modulesMetadata: modulesMetadata
        )
    }
}

extension Profile {
    var modulesBuilders: [any ModuleBuilder] {
        modules.compactMap {
            guard let buildableModule = $0 as? any BuildableType else {
                return nil
            }
            let builder = buildableModule.builder() as any BuilderType
            return builder as? any ModuleBuilder
        }
    }
}
