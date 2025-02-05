//
//  AppCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 10/29/24.
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
import UILibrary

public struct AppCoordinator: View, AppCoordinatorConforming {

    @EnvironmentObject
    public var iapManager: IAPManager

    private let profileManager: ProfileManager

    public let tunnel: ExtendedTunnel

    private let registry: Registry

    @State
    private var paywallReason: PaywallReason?

    @State
    private var onCancelPaywall: (() -> Void)?

    @StateObject
    private var interactiveManager = InteractiveManager()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    public init(profileManager: ProfileManager, tunnel: ExtendedTunnel, registry: Registry) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        debugChanges()
        return NavigationStack {
            TabView {
                profileView
                    .tabItem {
                        Text(Strings.Global.Nouns.profile)
                    }

//                searchView
//                    .tabItem {
//                        ThemeImage(.search)
//                    }

                settingsView
                    .tabItem {
                        ThemeImage(.settings)
                    }
            }
            .navigationDestination(for: AppCoordinatorRoute.self, destination: pushDestination)
            .modifier(PaywallModifier(
                reason: $paywallReason,
                onCancel: onCancelPaywall
            ))
            .withErrorHandler(errorHandler)
        }
    }
}

private extension AppCoordinator {
    var profileView: some View {
        ProfileView(
            profileManager: profileManager,
            tunnel: tunnel,
            interactiveManager: interactiveManager,
            errorHandler: errorHandler,
            flow: .init(
                onConnect: {
                    await onConnect($0, force: false)
                },
                onProviderEntityRequired: {
                    onProviderEntityRequired($0, force: false)
                }
            )
        )
    }

//    var searchView: some View {
//        VStack {
//            Text("Search")
//        }
//    }

    var settingsView: some View {
        SettingsView(tunnel: tunnel)
    }
}

private extension AppCoordinator {

    @ViewBuilder
    func pushDestination(_ item: AppCoordinatorRoute?) -> some View {
        switch item {
        case .appLog:
            DebugLogView(withAppParameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }

        case .tunnelLog:
            DebugLogView(withTunnel: tunnel, parameters: Constants.shared.log) {
                DebugLogContentView(lines: $0)
            }

        default:
            EmptyView()
        }
    }
}

// MARK: - Handlers

extension AppCoordinator {
    public func onInteractiveLogin(_ profile: Profile, _ onComplete: @escaping InteractiveManager.CompletionBlock) {
        pp_log(.app, .info, "Present interactive login")
        interactiveManager.present(
            with: profile,
            onComplete: onComplete
        )
    }

    public func onProviderEntityRequired(_ profile: Profile, force: Bool) {
        errorHandler.handle(
            title: profile.name,
            message: Strings.Alerts.Providers.MissingServer.message
        )
    }

    public func onPurchaseRequired(_ features: Set<AppFeature>, onCancel: (() -> Void)?) {
        pp_log(.app, .info, "Purchase required for features: \(features)")
        guard !iapManager.isLoadingReceipt else {
            let V = Strings.Views.Paywall.Alerts.Verification.self
            pp_log(.app, .info, "Present verification alert")
            errorHandler.handle(
                title: Strings.Views.Paywall.Alerts.Confirmation.title,
                message: [
                    V.Connect._1,
                    V.boot,
                    V.Connect._2(Constants.shared.tunnel.verificationDelayMinutes(ifRestricted: iapManager.isBeta))
                ].joined(separator: " "),
                onDismiss: onCancel
            )
            return
        }
        pp_log(.app, .info, "Present paywall")
        onCancelPaywall = onCancel
        setLater(.init(features, needsConfirmation: true)) {
            paywallReason = $0
        }
    }

    public func onError(_ error: Error, profile: Profile) {
        errorHandler.handle(
            error,
            title: profile.name,
            message: Strings.Errors.App.tunnel
        )
    }
}

// MARK: - Previews

#Preview {
    AppCoordinator(
        profileManager: .forPreviews,
        tunnel: .forPreviews,
        registry: Registry()
    )
    .withMockEnvironment()
}
