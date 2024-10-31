//
//  AppCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/13/24.
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
import CommonLibrary
import PassepartoutKit
import SwiftUI
import UtilsLibrary

public struct AppCoordinator: View, SizeClassProviding {

    @Environment(\.horizontalSizeClass)
    public var hsClass

    @Environment(\.verticalSizeClass)
    public var vsClass

    @AppStorage(AppPreference.profilesLayout.key)
    private var layout: ProfilesLayout = .list

    private let profileManager: ProfileManager

    private let tunnel: Tunnel

    private let registry: Registry

    @StateObject
    private var profileEditor = ProfileEditor()

    public init(
        profileManager: ProfileManager,
        tunnel: Tunnel,
        registry: Registry
    ) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        if isBigDevice {
            AppModalCoordinator(
                layout: $layout,
                profileManager: profileManager,
                profileEditor: profileEditor,
                tunnel: tunnel,
                registry: registry
            )
        } else {
            AppInlineCoordinator(
                layout: $layout,
                profileManager: profileManager,
                profileEditor: profileEditor,
                tunnel: tunnel,
                registry: registry
            )
        }
    }
}
