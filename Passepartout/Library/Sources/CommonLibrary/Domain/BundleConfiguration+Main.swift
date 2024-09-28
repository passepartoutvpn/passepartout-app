//
//  BundleConfiguration+Main.swift
//  Passepartout
//
//  Created by Davide De Rosa on 7/1/24.
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

extension BundleConfiguration {
    public enum BundleKey: String {
        case appId

        case appStoreId

        case customUserLevel

        case groupId

        case iapBundlePrefix

        case keychainGroupId

        case profilesContainerName

        case teamId

        case tunnelId
    }

    // WARNING: nil from package itself, e.g. in previews
    public static let main: BundleConfiguration? = {
        BundleConfiguration(.main, key: Constants.shared.bundle)
    }()

    public static var mainDisplayName: String {
        if isPreview {
            return "preview-display-name"
        }
        guard let main else {
            fatalError("Missing main bundle")
        }
        return main.displayName
    }

    public static var mainVersionString: String {
        if isPreview {
            return "preview-version-string"
        }
        guard let main else {
            fatalError("Missing main bundle")
        }
        return main.versionString
    }

    public static func mainString(for key: BundleKey) -> String {
        if isPreview {
            return "preview-bundle-key(\(key.rawValue))"
        }
        guard let main else {
            fatalError("Missing main bundle")
        }
        guard let value: String = main.value(forKey: key.rawValue) else {
            fatalError("Missing main bundle key: \(key.rawValue)")
        }
        return value
    }

    public static func mainIntegerIfPresent(for key: BundleKey) -> Int? {
        main?.value(forKey: key.rawValue)
    }
}

private extension BundleConfiguration {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
