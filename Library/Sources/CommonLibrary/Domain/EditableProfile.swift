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

public struct EditableProfile: MutableProfileType {
    public var id: UUID

    public var name: String

    public var modules: [any ModuleBuilder]

    public var activeModulesIds: Set<UUID>

    public var userInfo: AnyHashable?

    public init(
        id: UUID = UUID(),
        name: String = "",
        modules: [any ModuleBuilder] = [],
        activeModulesIds: Set<UUID> = [],
        userInfo: AnyHashable? = nil
    ) {
        self.id = id
        self.name = name
        self.modules = modules
        self.activeModulesIds = activeModulesIds
        self.userInfo = userInfo
    }

    public func builder() throws -> Profile.Builder {
        var builder = Profile.Builder(id: id)
        builder.modules = try modules.compactMap {
            do {
                return try $0.tryBuild()
            } catch {
                throw AppError.malformedModule($0, error: error)
            }
        }
        builder.activeModulesIds = activeModulesIds

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            throw AppError.emptyProfileName
        }
        builder.name = trimmedName
        builder.userInfo = userInfo

        return builder
    }
}

extension Profile {
    public func editable() -> EditableProfile {
        EditableProfile(
            id: id,
            name: name,
            modules: modulesBuilders(),
            activeModulesIds: activeModulesIds,
            userInfo: userInfo
        )
    }

    public func modulesBuilders() -> [any ModuleBuilder] {
        modules.compactMap {
            $0.moduleBuilder()
        }
    }
}

extension Module {
    public func moduleBuilder() -> (any ModuleBuilder)? {
        guard let buildableModule = self as? any BuildableType else {
            return nil
        }
        let builder = buildableModule.builder() as any BuilderType
        return builder as? any ModuleBuilder
    }
}

// MARK: -

private extension EditableProfile {
    var activeConnectionModule: (any ModuleBuilder)? {
        modules.first {
            isActiveModule(withId: $0.id) && $0.buildsConnectionModule
        }
    }
}
