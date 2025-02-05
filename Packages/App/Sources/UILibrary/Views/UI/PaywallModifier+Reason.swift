//
//  PaywallModifier+Reason.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/14/24.
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

import CommonIAP
import Foundation

public typealias PaywallReason = PaywallModifier.Reason

extension PaywallModifier {
    public struct Reason: Hashable {
        public let requiredFeatures: Set<AppFeature>

        public let needsConfirmation: Bool

        public let forConnecting: Bool

        public init(
            _ requiredFeatures: Set<AppFeature>,
            needsConfirmation: Bool = false,
            forConnecting: Bool = true
        ) {
            self.requiredFeatures = requiredFeatures
            self.needsConfirmation = needsConfirmation
            self.forConnecting = forConnecting
        }
    }
}
