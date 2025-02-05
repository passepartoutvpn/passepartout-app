//
//  AppCoordinator.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/13/24.
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

public struct AppCoordinator: View, AppCoordinatorConforming, SizeClassProviding {

    @EnvironmentObject
    public var iapManager: IAPManager

    @Environment(\.isUITesting)
    private var isUITesting

    @Environment(\.horizontalSizeClass)
    public var hsClass

    @Environment(\.verticalSizeClass)
    public var vsClass

    @AppStorage(UIPreference.profilesLayout.key)
    private var layout: ProfilesLayout = .list

    private let profileManager: ProfileManager

    public let tunnel: ExtendedTunnel

    private let registry: Registry

    @State
    private var isImporting = false

    @State
    private var paywallReason: PaywallReason?

    @State
    private var onCancelPaywall: (() -> Void)?

    @State
    private var modalRoute: ModalRoute?

    @State
    private var profilePath = NavigationPath()

    @State
    private var migrationPath = NavigationPath()

    @StateObject
    private var profileEditor = ProfileEditor()

    @StateObject
    private var interactiveManager = InteractiveManager()

    @StateObject
    private var errorHandler: ErrorHandler = .default()

    public init(
        profileManager: ProfileManager,
        tunnel: ExtendedTunnel,
        registry: Registry
    ) {
        self.profileManager = profileManager
        self.tunnel = tunnel
        self.registry = registry
    }

    public var body: some View {
        NavigationStack {
            contentView
                .toolbar(content: toolbarContent)
        }
        .modifier(OnboardingModifier(modalRoute: $modalRoute))
        .modifier(PaywallModifier(
            reason: $paywallReason,
            onCancel: onCancelPaywall
        ))
        .themeModal(
            item: $modalRoute,
            options: modalRoute?.options(),
            content: modalDestination
        )
        .withErrorHandler(errorHandler)
        .onChange(of: interactiveManager.isPresented) {
            modalRoute = $0 ? .interactiveLogin : nil
        }
    }
}

// MARK: -

extension AppCoordinator {
    var contentView: some View {
        ProfileContainerView(
            layout: overriddenLayout,
            profileManager: profileManager,
            tunnel: tunnel,
            registry: registry,
            isImporting: $isImporting,
            errorHandler: errorHandler,
            flow: .init(
                onEditProfile: onEditProfile,
                onMigrateProfiles: {
                    modalRoute = .migrateProfiles
                },
                connectionFlow: .init(
                    onConnect: {
                        await onConnect($0, force: false)
                    },
                    onProviderEntityRequired: {
                        onProviderEntityRequired($0, force: false)
                    }
                )
            )
        )
    }

    var overriddenLayout: ProfilesLayout {
        if isUITesting {
            return isBigDevice ? .grid : .list
        }
        guard isBigDevice else {
            return .list
        }
        return layout
    }

    var migrateViewStyle: MigrateView.Style {
#if os(iOS)
        .list
#else
        .table
#endif
    }

    func toolbarContent() -> some ToolbarContent {
        AppToolbar(
            profileManager: profileManager,
            registry: registry,
            layout: $layout,
            isImporting: $isImporting,
            onPreferences: {
                present(.preferences)
            },
            onAbout: {
                present(.about)
            },
            onMigrateProfiles: {
                present(.migrateProfiles)
            },
            onNewProfile: onNewProfile
        )
    }

    @ViewBuilder
    func modalDestination(for item: ModalRoute?) -> some View {
        switch item {
        case .about:
            AboutCoordinator(
                profileManager: profileManager,
                tunnel: tunnel
            )

        case .editProfile(let initialModuleId):
            ProfileCoordinator(
                profileManager: profileManager,
                profileEditor: profileEditor,
                initialModuleId: initialModuleId,
                registry: registry,
                moduleViewFactory: DefaultModuleViewFactory(registry: registry),
                path: $profilePath,
                onDismiss: onDismiss
            )

        case .editProviderEntity(let profile, let force, let module):
            ProviderServerCoordinatorIfSupported(
                module: module,
                errorHandler: errorHandler,
                selectTitle: profile.providerServerSelectionTitle,
                onSelect: {
                    try await onSelectProviderEntity(with: $0, in: profile, force: force)
                }
            )

        case .interactiveLogin:
            InteractiveCoordinator(style: .modal, manager: interactiveManager) {
                errorHandler.handle(
                    $0,
                    title: interactiveManager.editor.profile.name,
                    message: Strings.Errors.App.tunnel
                )
            }
            .presentationDetents([.medium])

        case .migrateProfiles:
            MigrateView(
                style: migrateViewStyle,
                profileManager: profileManager
            )
            .themeNavigationStack(closable: true, path: $migrationPath)

        case .preferences:
            PreferencesView(profileManager: profileManager)

        default:
            EmptyView()
        }
    }
}

// MARK: - Providers

private struct ProviderServerCoordinatorIfSupported: View {
    let module: Module

    let errorHandler: ErrorHandler

    let selectTitle: String

    let onSelect: (Module) async throws -> Void

    var body: some View {
        if let supporting = module as? any ProviderServerCoordinatorSupporting {
            supporting.providerServerCoordinator(
                selectTitle: selectTitle,
                onSelect: onSelect,
                errorHandler: errorHandler
            )
        } else {
            fatalError("Module got too far without being ProviderServerCoordinatorSupporting: \(module)")
        }
    }
}

// MARK: - Handlers

extension AppCoordinator {
    public func onInteractiveLogin(_ profile: Profile, _ onComplete: @escaping InteractiveManager.CompletionBlock) {
        pp_log(.app, .info, "Present interactive login")
        interactiveManager.present(with: profile, onComplete: onComplete)
    }

    public func onProviderEntityRequired(_ profile: Profile, force: Bool) {
        guard let module = profile.selectedProvider?.module else {
            assertionFailure("Editing provider entity, but profile has no selected provider module")
            return
        }
        pp_log(.app, .info, "Present provider entity selector")
        present(.editProviderEntity(profile, force, module))
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
                    V.Connect._2(Constants.shared.tunnel.verificationDelayMinutes(isBeta: iapManager.isBeta))
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

private extension AppCoordinator {
    func onSelectProviderEntity(with newModule: Module, in profile: Profile, force: Bool) async throws {

        // XXX: select entity after dismissing
        try await Task.sleep(for: .milliseconds(500))

        pp_log(.app, .info, "Select new provider entity: (profile=\(profile.id), module=\(newModule.id))")

        do {
            var builder = profile.builder()
            builder.saveModule(newModule)
            let newProfile = try builder.tryBuild()

            let wasConnected = newProfile.id == tunnel.currentProfile?.id && tunnel.status == .active
            try await profileManager.save(newProfile, isLocal: true)

            guard profile.shouldConnectToProviderServer else {
                return
            }

            if !wasConnected {
                pp_log(.app, .info, "Profile \(newProfile.id) was not connected, will connect to new provider entity")
                await onConnect(newProfile, force: force)
            } else {
                pp_log(.app, .info, "Profile \(newProfile.id) was connected, will reconnect to new provider entity via AppContext observation")
            }
        } catch {
            pp_log(.app, .error, "Unable to save new provider entity: \(error)")
            throw error
        }
    }

    func onNewProfile(_ profile: EditableProfile, initialModuleId: UUID?) {
        editProfile(profile, initialModuleId: initialModuleId)
    }

    func onEditProfile(_ preview: ProfilePreview) {
        guard let profile = profileManager.profile(withId: preview.id) else {
            return
        }
        editProfile(profile.editable(), initialModuleId: nil)
    }

    func editProfile(_ profile: EditableProfile, initialModuleId: UUID?) {
        profilePath = NavigationPath()
        let isShared = profileManager.isRemotelyShared(profileWithId: profile.id)
        profileEditor.load(profile, isShared: isShared)
        present(.editProfile(initialModuleId))
    }
}

private extension AppCoordinator {
    func present(_ route: ModalRoute?) {
        setLater(route) {
            modalRoute = $0
        }
    }

    func onDismiss() {
        present(nil)
    }
}

private extension Profile {
    var providerServerSelectionTitle: String {
        attributes.isAvailableForTV == true ? Strings.Views.Providers.selectEntity : Strings.Global.Actions.connect
    }

    var shouldConnectToProviderServer: Bool {
#if os(tvOS)
        true
#else
        // do not connect TV profiles on server selection
        attributes.isAvailableForTV != true
#endif
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
