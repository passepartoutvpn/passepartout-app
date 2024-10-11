//
//  NEProfileRepository.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/10/24.
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

import Combine
import CommonLibrary
import Foundation
import NetworkExtension
import PassepartoutKit

public final class NEProfileRepository: ProfileRepository {
    private let repository: NETunnelManagerRepository

    private let title: (Profile) -> String

    private let profilesSubject: CurrentValueSubject<[Profile], Never>

    private var subscription: AnyCancellable?

    public init(repository: NETunnelManagerRepository, keychain: Keychain, title: @escaping (Profile) -> String) {
        self.repository = repository
        self.title = title
        profilesSubject = CurrentValueSubject([])

        subscription = repository
            .managersPublisher
            .sink { [weak self] allManagers in
                var toRemove: [NETunnelProviderManager] = []
                let profiles = allManagers.values.compactMap {
                    do {
                        return try repository.profile(from: $0)
                    } catch {
                        pp_log(.app, .error, "Unable to decode profile, will delete NE manager '\($0.localizedDescription ?? "")': \(error)")
                        toRemove.append($0)
                        pp_log(.app, .error, "Unable to decode profile from NE manager '\($0.localizedDescription ?? "")': \(error)")
                        return nil
                    }
                }
                self?.profilesSubject.send(profiles)

                let toRemoveConstant = toRemove
                Task {
                    for manager in toRemoveConstant {
                        try? await repository.remove(manager: manager, keychain: keychain)
                    }
                }
            }

        Task {
            do {
                try await repository.load()
            } catch {
                pp_log(.app, .fault, "Unable to load NE profiles: \(error)")
            }
        }
    }

    public var profilesPublisher: AnyPublisher<[Profile], Never> {
        profilesSubject.eraseToAnyPublisher()
    }

    public func saveProfile(_ profile: Profile) async throws {
        try await repository.save(profile, connect: false, title: title)
    }

    public func removeProfiles(withIds profileIds: [Profile.ID]) async throws {
        for id in profileIds {
            try await repository.remove(profileId: id)
        }
    }
}
