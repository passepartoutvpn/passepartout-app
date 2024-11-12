//
//  LegacyV2.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/1/24.
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
import Foundation
import PassepartoutKit

public final class LegacyV2 {
    private let profilesRepository: CDProfileRepositoryV2

    private let cloudKitIdentifier: String?

    public init(
        coreDataLogger: CoreDataPersistentStoreLogger?,
        profilesContainerName: String,
        baseURL: URL,
        cloudKitIdentifier: String?
    ) {
        let store = CoreDataPersistentStore(
            logger: coreDataLogger,
            containerName: profilesContainerName,
            baseURL: baseURL,
            model: CDProfileRepositoryV2.model,
            cloudKitIdentifier: cloudKitIdentifier,
            author: nil
        )
        profilesRepository = CDProfileRepositoryV2(context: store.context)
        self.cloudKitIdentifier = cloudKitIdentifier
    }
}

// MARK: - Mapping

extension LegacyV2 {
    public func migratableProfiles() async throws -> [MigratableProfile] {
        let profilesV2 = try await fetchProfilesV2()
        return profilesV2.map {
            MigratableProfile(id: $0.id, name: $0.header.name, lastUpdate: $0.header.lastUpdate)
        }
    }

    public func fetchProfiles(selection: Set<UUID>) async throws -> [Profile] {
        let profilesV2 = try await fetchProfilesV2()
        let mapper = MapperV2()
        return profilesV2
            .filter {
                selection.contains($0.id)
            }
            .map {
                mapper.toProfileV3($0)
            }
    }
}

// MARK: - Legacy profiles

extension LegacyV2 {
    func fetchProfilesV2() async throws -> [ProfileV2] {
        try await profilesRepository.profiles()
    }
}
