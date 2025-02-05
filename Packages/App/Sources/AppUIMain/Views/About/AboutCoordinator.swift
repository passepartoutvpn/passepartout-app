//
//  AboutCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/22/24.
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
import PassepartoutKit
import SwiftUI
import UILibrary

struct AboutCoordinator: View {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Environment(\.dismiss)
    private var dismiss

    let profileManager: ProfileManager

    let tunnel: ExtendedTunnel

    @State
    private var path = NavigationPath()

    @State
    private var navigationRoute: AboutCoordinatorRoute?

    var body: some View {
        AboutContentView(
            profileManager: profileManager,
            isRestricted: iapManager.isBeta,
            path: $path,
            navigationRoute: $navigationRoute,
            linkContent: linkView(to:),
            aboutDestination: pushDestination(for:),
            logDestination: pushDestination(for:)
        )
    }
}

extension AboutCoordinator {
    func linkView(to route: AboutCoordinatorRoute) -> some View {
        NavigationLink(value: route) {
            linkLabel(for: route)
        }
    }

    func title(for route: AboutCoordinatorRoute) -> String {
        switch route {
        case .credits:
            Strings.Views.About.Credits.title

        case .diagnostics:
            Strings.Views.Diagnostics.title

        case .donate:
            Strings.Views.Donate.title

        case .links:
            Strings.Views.About.Links.title

        case .purchased:
            Strings.Global.Nouns.purchases

        case .version:
            Strings.Views.About.title
        }
    }

    @ViewBuilder
    func linkLabel(for route: AboutCoordinatorRoute) -> some View {
        switch route {
        case .version:
            Text(Strings.Global.Nouns.version)
#if os(iOS)
                .themeTrailingValue(BundleConfiguration.mainVersionString)
#endif

        default:
            Text(title(for: route))
        }
    }

    @ViewBuilder
    func pushDestination(for item: AboutCoordinatorRoute?) -> some View {
        switch item {
        case .credits:
            CreditsView()
                .navigationTitle(title(for: .credits))

        case .diagnostics:
            DiagnosticsView(profileManager: profileManager, tunnel: tunnel)
                .navigationTitle(title(for: .diagnostics))

        case .donate:
            DonateView(modifier: DonateViewModifier())
                .navigationTitle(title(for: .donate))

        case .links:
            LinksView()
                .navigationTitle(title(for: .links))

        case .purchased:
            PurchasedView()
                .navigationTitle(title(for: .purchased))

        case .version:
            VersionView()

        default:
            Text(Strings.Global.Nouns.noSelection)
                .themeEmptyMessage()
        }
    }

    @ViewBuilder
    func pushDestination(for item: DebugLogRoute?) -> some View {
        switch item {
        case .app(let title):
            DebugLogView(withAppParameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }
            .navigationTitle(title)

        case .tunnel(let title, let url):
            if let url {
                DebugLogView(withURL: url) {
                    DebugLogContentView(lines: $0)
                }
                .navigationTitle(title)
            } else {
                DebugLogView(withTunnel: tunnel, parameters: Constants.shared.log) {
                    DebugLogContentView(lines: $0)
                }
                .navigationTitle(title)
            }

        default:
            Text(Strings.Global.Nouns.noSelection)
                .themeEmptyMessage()
        }
    }
}

#Preview {
    AboutCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews
    )
    .withMockEnvironment()
}
