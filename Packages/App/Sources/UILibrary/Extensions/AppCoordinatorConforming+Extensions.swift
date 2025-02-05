//
//  AppCoordinatorConforming+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/1/24.
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

extension AppCoordinatorConforming {
    public func onConnect(_ profile: Profile, force: Bool, verify: Bool = true) async {
        do {
            if verify {
                try iapManager.verify(profile)
            }
            try await tunnel.connect(with: profile, force: force)
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            onPurchaseRequired(requiredFeatures) {
                Task {
                    await onConnect(profile, force: force, verify: false)
                }
            }
        } catch AppError.interactiveLogin {
            onInteractiveLogin(profile) { newProfile in
                Task {
                    await onConnect(newProfile, force: true, verify: verify)
                }
            }
        } catch let ppError as PassepartoutError {
            switch ppError.code {
            case .missingProviderEntity:
                onProviderEntityRequired(profile, force: force)
            default:
                onError(ppError, profile: profile)
            }
        } catch {
            onError(error, profile: profile)
        }
    }
}
