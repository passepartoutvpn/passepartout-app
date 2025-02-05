//
//  DefaultAppProcessor.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/6/24.
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

final class DefaultAppProcessor: Sendable {
    private let iapManager: IAPManager

    private let title: @Sendable (Profile) -> String

    init(
        iapManager: IAPManager,
        title: @escaping @Sendable (Profile) -> String
    ) {
        self.iapManager = iapManager
        self.title = title
    }
}

extension DefaultAppProcessor: ProfileProcessor {
    func isIncluded(_ profile: Profile) -> Bool {
#if os(tvOS)
        profile.attributes.isAvailableForTV == true
#else
        true
#endif
    }

    func preview(from profile: Profile) -> ProfilePreview {
        profile.localizedPreview
    }

    func requiredFeatures(_ profile: Profile) -> Set<AppFeature>? {
        do {
            try iapManager.verify(profile)
            return nil
        } catch AppError.ineligibleProfile(let requiredFeatures) {
            return requiredFeatures
        } catch {
            return nil
        }
    }

    func willRebuild(_ builder: Profile.Builder) throws -> Profile.Builder {
        builder
    }
}

extension DefaultAppProcessor: AppTunnelProcessor {
    func title(for profile: Profile) -> String {
        title(profile)
    }

    func willInstall(_ profile: Profile) throws -> Profile {

        // validate provider modules
        do {
            _ = try profile.withProviderModules()
            return profile
        } catch {
            pp_log(.app, .error, "Unable to inject provider modules: \(error)")
            throw error
        }
    }
}
