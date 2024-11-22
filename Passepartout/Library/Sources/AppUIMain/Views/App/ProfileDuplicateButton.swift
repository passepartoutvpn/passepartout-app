//
//  ProfileDuplicateButton.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/6/24.
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

import CommonLibrary
import CommonUtils
import SwiftUI

struct ProfileDuplicateButton<Label>: View where Label: View {
    let profileManager: ProfileManager

    let preview: ProfilePreview

    let errorHandler: ErrorHandler

    let label: () -> Label

    var body: some View {
        Button {
            Task {
                do {
                    try await profileManager.duplicate(profileWithId: preview.id)
                } catch {
                    errorHandler.handle(
                        error,
                        title: Strings.Global.duplicate,
                        message: Strings.Views.Profiles.Errors.duplicate(preview.name)
                    )
                }
            }
        } label: {
            label()
        }
    }
}
