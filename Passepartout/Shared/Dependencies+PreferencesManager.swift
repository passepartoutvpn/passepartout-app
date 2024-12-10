//
//  Dependencies+PreferencesManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 12/2/24.
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

import AppData
import AppDataPreferences
import CommonLibrary
import CommonUtils
import Foundation
import PassepartoutKit

extension Dependencies {
    func preferencesManager(withCloudKit: Bool) -> PreferencesManager {
        let preferencesStore = CoreDataPersistentStore(
            logger: coreDataLogger(),
            containerName: Constants.shared.containers.preferences,
            baseURL: BundleConfiguration.urlForGroupDocuments,
            model: AppData.cdPreferencesModel,
            cloudKitIdentifier: withCloudKit ? BundleConfiguration.mainString(for: .cloudKitPreferencesId) : nil,
            author: nil
        )
        return PreferencesManager(
            providersFactory: {
                try AppData.cdProviderPreferencesRepositoryV3(
                    context: preferencesStore.context,
                    providerId: $0
                )
            }
        )
    }
}
