//
//  StorageSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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
import SwiftUI

struct StorageSection: View {
    let uuid: UUID

    @Binding
    var isShared: Bool

    var body: some View {
        debugChanges()
        return Section {
            Section {
                Toggle(Strings.Modules.General.Storage.shared, isOn: $isShared)
            }
#if DEBUG
            ThemeCopiableText(
                title: Strings.Unlocalized.uuid,
                value: uuid.uuidString
            )
#endif
        } header: {
            Text(Strings.Global.storage)
        }
    }
}

#Preview {
    Form {
        StorageSection(
            uuid: ProfileEditor().id,
            isShared: .constant(false)
        )
    }
    .themeForm()
    .withMockEnvironment()
}
