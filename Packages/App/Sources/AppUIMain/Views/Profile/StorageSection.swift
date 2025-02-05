//
//  StorageSection.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/4/24.
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
import SwiftUI

struct StorageSection: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @ObservedObject
    var profileEditor: ProfileEditor

    var body: some View {
        debugChanges()
        return Group {
            sharingToggle
                .themeRowWithSubtitle(sharingDescription)
            tvToggle
                .themeRowWithSubtitle(tvDescription)
        }
        .themeSection(header: header, footer: footer)
    }
}

private extension StorageSection {
    var sharingToggle: some View {
        Toggle(isOn: $profileEditor.isShared) {
            HStack {
                Text(Strings.Modules.General.Rows.shared)
                PurchaseRequiredView(features: profileEditor.isShared ? [.sharing] : [])
            }
        }
    }

    var tvToggle: some View {
        Toggle(isOn: $profileEditor.isAvailableForTV) {
            HStack {
                Text(Strings.Modules.General.Rows.appletv(Strings.Unlocalized.appleTV))
                PurchaseRequiredView(features: profileEditor.isAvailableForTV ? [.appleTV] : [])
            }
        }
        .disabled(!profileEditor.isShared)
    }
}

private extension StorageSection {
    var header: String {
        Strings.Modules.General.Sections.Storage.header(Strings.Unlocalized.iCloud)
    }

    var footer: String {
        var desc = [
            Strings.Modules.General.Sections.Storage.footer(Strings.Unlocalized.iCloud)
        ]
        if let tvDescription {
            desc.append(tvDescription)
        }
        return desc.joined(separator: " ")
    }

    var sharingDescription: String {
        Strings.Modules.General.Sections.Storage.footer(Strings.Unlocalized.iCloud)
    }

    var tvDescription: String? {
        if iapManager.isEligible(for: .appleTV) {
            return nil
        }
        if !iapManager.isBeta {
            return Strings.Modules.General.Sections.Storage.Footer.Purchase.tvRelease
        } else {
            return Strings.Modules.General.Sections.Storage.Footer.Purchase.tvBeta
        }
    }
}

#Preview {
    Form {
        StorageSection(profileEditor: ProfileEditor())
    }
    .themeForm()
    .withMockEnvironment()
}
