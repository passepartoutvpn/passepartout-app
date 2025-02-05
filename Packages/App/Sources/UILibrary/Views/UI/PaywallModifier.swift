//
//  PaywallModifier.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/11/24.
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
import SwiftUI

public struct PaywallModifier: ViewModifier {

    @EnvironmentObject
    private var iapManager: IAPManager

    @Binding
    private var reason: PaywallReason?

    private let onCancel: (() -> Void)?

    @State
    private var isConfirming = false

    @State
    private var isRestricted = false

    @State
    private var isPurchasing = false

    public init(reason: Binding<PaywallReason?>, onCancel: (() -> Void)? = nil) {
        _reason = reason
        self.onCancel = onCancel
    }

    public func body(content: Content) -> some View {
        content
            .alert(
                Strings.Views.Paywall.Alerts.Confirmation.title,
                isPresented: $isConfirming,
                actions: confirmationActions,
                message: confirmationMessage
            )
            .alert(
                Strings.Views.Paywall.Alerts.Restricted.title,
                isPresented: $isRestricted,
                actions: restrictedActions,
                message: restrictedMessage
            )
            .themeModal(
                isPresented: $isPurchasing,
                options: .init(size: .custom(width: 400, height: 400)),
                content: modalDestination
            )
            .onChange(of: isRestricted) {
                if !$0 {
                    reason = nil
                }
            }
            .onChange(of: isPurchasing) {
                if !$0 {
                    reason = nil
                }
            }
            .onChange(of: reason) {
                guard let reason = $0 else {
                    return
                }
                if !iapManager.isBeta {
                    if reason.needsConfirmation {
                        isConfirming = true
                    } else {
                        isPurchasing = true
                    }
                } else {
                    isRestricted = true
                }
            }
    }
}

private extension PaywallModifier {
    func alertMessage(startingWith header: String, features: [String]) -> String {
        header + "\n\n" + features.joined(separator: "\n")

    }
}

// MARK: - Confirmation alert

private extension PaywallModifier {

    @ViewBuilder
    func confirmationActions() -> some View {
        Button(Strings.Global.Actions.purchase) {
            // IMPORTANT: retain reason because it serves paywall content
            isPurchasing = true
        }
        Button(Strings.Global.Actions.cancel, role: .cancel) {
            reason = nil
            onCancel?()
        }
    }

    func confirmationMessage() -> some View {
        Text(confirmationMessageString)
    }

    var confirmationMessageString: String {
        let V = Strings.Views.Paywall.Alerts.Confirmation.self
        var messages = [V.message]
        if reason?.forConnecting == true {
            messages.append(V.Message.connect(limitedMinutes))
        }
        return alertMessage(
            startingWith: messages.joined(separator: " "),
            features: ineligibleFeatures
        )
    }
}

// MARK: - Restricted alert

private extension PaywallModifier {
    func restrictedActions() -> some View {
        Button(Strings.Global.Nouns.ok) {
            onCancel?()
        }
    }

    func restrictedMessage() -> some View {
        Text(restrictedMessageString)
    }

    var restrictedMessageString: String {
        let V = Strings.Views.Paywall.Alerts.self
        var messages = [V.Restricted.message]
        if reason?.forConnecting == true {
            messages.append(V.Confirmation.Message.connect(limitedMinutes))
        }
        return alertMessage(
            startingWith: messages.joined(separator: " "),
            features: ineligibleFeatures
        )
    }
}

// MARK: - Paywall

private extension PaywallModifier {
    func modalDestination() -> some View {
        assert(!iapManager.isLoadingReceipt, "Paywall presented while still loading receipt?")
        return reason.map {
            PaywallView(
                isPresented: $isPurchasing,
                features: iapManager.excludingEligible(from: $0.requiredFeatures)
            )
            .themeNavigationStack()
        }
    }
}

// MARK: - Logic

private extension PaywallModifier {
    var ineligibleFeatures: [String] {
        guard let reason else {
            return []
        }
        return iapManager
            .excludingEligible(from: reason.requiredFeatures)
            .map(\.localizedDescription)
            .sorted()
    }

    var limitedMinutes: Int {
        let params = Constants.shared.tunnel.verificationParameters(isBeta: iapManager.isBeta)
        return Int(params.delay / 60.0)
    }
}

private extension IAPManager {
    func excludingEligible(from features: Set<AppFeature>) -> Set<AppFeature> {
        features.filter {
            !isEligible(for: $0)
        }
    }
}
