//
//  BundleConfiguration+AppGroup.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/4/24.
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

import Foundation
import PassepartoutKit

// WARNING: beware of Constants.shared dependency

extension BundleConfiguration {
    public static var urlForAppLog: URL {
        urlForCaches.appending(path: Constants.shared.log.appPath)
    }

    public static var urlForTunnelLog: URL {
        urlForCaches.appending(path: Constants.shared.log.tunnelPath)
    }
}

// App Group container is not available on tvOS (#1007)

#if !os(tvOS)

extension BundleConfiguration {
    public static var urlForCaches: URL {
        let url = appGroupURL.appending(components: "Library", "Caches")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            pp_log(.app, .fault, "Unable to create group caches directory: \(error)")
        }
        return url
    }

    public static var urlForDocuments: URL {
        let url = appGroupURL.appending(components: "Library", "Documents")
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            pp_log(.app, .fault, "Unable to create group documents directory: \(error)")
        }
        return url
    }
}

private extension BundleConfiguration {
    static var appGroupURL: URL {
        let groupId = mainString(for: .groupId)
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId) else {
            pp_log(.app, .error, "Unable to access App Group container")
            return FileManager.default.temporaryDirectory
        }
        return url
    }
}

#else

extension BundleConfiguration {
    public static var urlForCaches: URL {
        do {
            return try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            pp_log(.app, .fault, "Unable to create user documents directory: \(error)")
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

    public static var urlForDocuments: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            pp_log(.app, .fault, "Unable to create user documents directory: \(error)")
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }
}

#endif
