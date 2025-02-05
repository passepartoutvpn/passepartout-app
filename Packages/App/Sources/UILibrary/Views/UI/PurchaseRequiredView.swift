//
//  PurchaseRequiredView.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/17/24.
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
import CommonUtils
import PassepartoutKit
import SwiftUI

public struct PurchaseRequiredView<Content>: View where Content: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    let features: Set<AppFeature>?

    @ViewBuilder
    let content: (_ isRestricted: Bool) -> Content

    public var body: some View {
        content(iapManager.isBeta)
            .opaque(!isEligible)
    }
}

private extension PurchaseRequiredView {
    var isEligible: Bool {
        if let features {
            return iapManager.isEligible(for: features)
        }
        return true
    }
}

// MARK: - Initializers

extension PurchaseRequiredView where Content == PurchaseRequiredImage {
    public init(for requiring: AppFeatureRequiring?) {
        self.init(features: requiring?.features)
    }

    public init(features: Set<AppFeature>?) {
        self.features = features
        content = {
            PurchaseRequiredImage(isRestricted: $0)
        }
    }
}

public struct PurchaseRequiredImage: View {

    @EnvironmentObject
    private var theme: Theme

    let isRestricted: Bool

    public var body: some View {
        ThemeImage(isRestricted ? .warning : .upgrade)
            .foregroundStyle(theme.upgradeColor)
            .help(isRestricted ? Strings.Views.Ui.PurchaseRequired.Restricted.help : Strings.Views.Ui.PurchaseRequired.Purchase.help)
#if os(macOS)
            .imageScale(.large)
#endif
    }
}
