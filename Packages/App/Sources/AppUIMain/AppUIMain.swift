//
//  AppUIMain.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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
import TipKit
@_exported import UILibrary

public final class AppUIMain: UILibraryConfiguring {
    public init() {
    }

    public func configure(with context: AppContext) {
        assertMissingImplementations(with: context.registry)

        if #available(iOS 17, macOS 14, *) {

            // for debugging
//            Tips.showAllTipsForTesting()

            try? Tips.configure([
                .displayFrequency(.immediate)
            ])
        }
    }
}

private extension AppUIMain {
    func assertMissingImplementations(with registry: Registry) {
        let providerModuleTypes: Set<ModuleType> = [
            .openVPN,
            .wireGuard
        ]
        ModuleType.allCases.forEach { moduleType in
            do {
                let builder = moduleType.newModule(with: registry)
                let module = try builder.tryBuild()

                // ModuleViewProviding
                guard builder is any ModuleViewProviding else {
                    fatalError("\(moduleType): is not ModuleViewProviding")
                }

                // ProviderServerCoordinatorSupporting
                if providerModuleTypes.contains(moduleType) {
                    guard module is any ProviderServerCoordinatorSupporting else {
                        fatalError("\(moduleType): is not ProviderServerCoordinatorSupporting")
                    }
                }
            } catch {
                if (error as? PassepartoutError)?.code == .incompleteModule {
                    return
                }
                fatalError("\(moduleType): empty module is not buildable: \(error)")
            }
        }
    }
}
