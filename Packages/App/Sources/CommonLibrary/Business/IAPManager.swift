//
//  IAPManager.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/10/24.
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

import Combine
import CommonUtils
import Foundation
import PassepartoutKit

@MainActor
public final class IAPManager: ObservableObject {
    private let customUserLevel: AppUserLevel?

    private let inAppHelper: any AppProductHelper

    private let receiptReader: AppReceiptReader

    private let betaChecker: BetaChecker

    private let unrestrictedFeatures: Set<AppFeature>

    private let productsAtBuild: BuildProducts<AppProduct>?

    private(set) var userLevel: AppUserLevel

    public private(set) var purchasedAppBuild: Int?

    public private(set) var purchasedProducts: Set<AppProduct>

    @Published
    public private(set) var eligibleFeatures: Set<AppFeature>

    @Published
    private var pendingReceiptTask: Task<Void, Never>?

    private var subscriptions: Set<AnyCancellable>

    public init(
        customUserLevel: AppUserLevel? = nil,
        inAppHelper: any AppProductHelper,
        receiptReader: AppReceiptReader,
        betaChecker: BetaChecker,
        unrestrictedFeatures: Set<AppFeature> = [],
        productsAtBuild: BuildProducts<AppProduct>? = nil
    ) {
        self.customUserLevel = customUserLevel
        self.inAppHelper = inAppHelper
        self.receiptReader = receiptReader
        self.betaChecker = betaChecker
        self.unrestrictedFeatures = unrestrictedFeatures
        self.productsAtBuild = productsAtBuild
        userLevel = .undefined
        purchasedProducts = []
        eligibleFeatures = []
        subscriptions = []
    }
}

// MARK: - Actions

extension IAPManager {
    public var isLoadingReceipt: Bool {
        pendingReceiptTask != nil
    }

    public func purchasableProducts(for products: [AppProduct]) async throws -> [InAppProduct] {
        do {
            let inAppProducts = try await inAppHelper.fetchProducts(timeout: Constants.shared.iap.productsTimeoutInterval)
            return products.compactMap {
                inAppProducts[$0]
            }
        } catch {
            pp_log(.App.iap, .error, "Unable to fetch in-app products: \(error)")
            throw error
        }
    }

    public func purchase(_ purchasableProduct: InAppProduct) async throws -> InAppPurchaseResult {
        let result = try await inAppHelper.purchase(purchasableProduct)
        if result == .done {
            await receiptReader.addPurchase(with: purchasableProduct.productIdentifier)
            await reloadReceipt()
        }
        return result
    }

    public func restorePurchases() async throws {
        try await inAppHelper.restorePurchases()
        await reloadReceipt()
    }

    public func reloadReceipt() async {
        if let pendingReceiptTask {
            await pendingReceiptTask.value
        }
        pendingReceiptTask = Task {
            await fetchLevelIfNeeded()
            await asyncReloadReceipt()
        }
        await pendingReceiptTask?.value
        pendingReceiptTask = nil
    }
}

// MARK: - Eligibility

extension IAPManager {
    public var isBeta: Bool {
        userLevel.isBeta
    }

    public func isEligible(for feature: AppFeature) -> Bool {
        eligibleFeatures.contains(feature)
    }

    public func isEligible<C>(for features: C) -> Bool where C: Collection, C.Element == AppFeature {
        if features.isEmpty {
            return true
        }
        return features.allSatisfy(eligibleFeatures.contains)
    }

    public var isEligibleForFeedback: Bool {
#if os(tvOS)
        false
#else
        userLevel == .beta || isPayingUser
#endif
    }

    public var isPayingUser: Bool {
        !purchasedProducts.isEmpty
    }
}

// MARK: - Receipt

private extension IAPManager {
    func asyncReloadReceipt() async {
        pp_log(.App.iap, .notice, "Start reloading in-app receipt...")

        var purchasedAppBuild: Int?
        var purchasedProducts: Set<AppProduct> = []
        var eligibleFeatures: Set<AppFeature> = []

        if let receipt = await receiptReader.receipt(at: userLevel) {
            if let originalBuildNumber = receipt.originalBuildNumber {
                purchasedAppBuild = originalBuildNumber
            }

            if let purchasedAppBuild {
                pp_log(.App.iap, .info, "Original purchased build: \(purchasedAppBuild)")

                // assume some purchases by build number
                let entitled = productsAtBuild?(purchasedAppBuild) ?? []
                pp_log(.App.iap, .notice, "Entitled features: \(entitled.map(\.rawValue))")

                entitled.forEach {
                    purchasedProducts.insert($0)
                }
            }
            if let iapReceipts = receipt.purchaseReceipts {
                pp_log(.App.iap, .info, "Process in-app purchase receipts...")

                let products: [AppProduct] = iapReceipts.compactMap {
                    guard let pid = $0.productIdentifier else {
                        return nil
                    }
                    guard let product = AppProduct(rawValue: pid) else {
                        pp_log(.App.iap, .debug, "\tDiscard unknown product identifier: \(pid)")
                        return nil
                    }
                    if let expirationDate = $0.expirationDate {
                        let now = Date()
                        pp_log(.App.iap, .debug, "\t\(pid) [expiration date: \(expirationDate), now: \(now)]")
                        if now >= expirationDate {
                            pp_log(.App.iap, .info, "\t\(pid) [expired on: \(expirationDate)]")
                            return nil
                        }
                    }
                    if let cancellationDate = $0.cancellationDate {
                        pp_log(.App.iap, .info, "\t\(pid) [cancelled on: \(cancellationDate)]")
                        return nil
                    }
                    if let purchaseDate = $0.originalPurchaseDate {
                        pp_log(.App.iap, .info, "\t\(pid) [purchased on: \(purchaseDate)]")
                    }
                    return product
                }

                products.forEach {
                    purchasedProducts.insert($0)
                }
            }

            eligibleFeatures = purchasedProducts.reduce(into: []) { eligible, product in
                product.features.forEach {
                    eligible.insert($0)
                }
            }
        } else {
            pp_log(.App.iap, .error, "Could not parse App Store receipt!")
        }

        userLevel.features.forEach {
            eligibleFeatures.insert($0)
        }
        unrestrictedFeatures.forEach {
            eligibleFeatures.insert($0)
        }

        pp_log(.App.iap, .notice, "Finished reloading in-app receipt for user level \(userLevel)")
        pp_log(.App.iap, .notice, "\tPurchased build number: \(purchasedAppBuild?.description ?? "unknown")")
        pp_log(.App.iap, .notice, "\tPurchased products: \(purchasedProducts.map(\.rawValue))")
        pp_log(.App.iap, .notice, "\tEligible features: \(eligibleFeatures)")

        self.purchasedAppBuild = purchasedAppBuild
        self.purchasedProducts = purchasedProducts
        self.eligibleFeatures = eligibleFeatures // @Published -> objectWillChange.send()
    }
}

// MARK: - Observation

extension IAPManager {
    public func observeObjects(withProducts: Bool = true) {
        Task {
            await fetchLevelIfNeeded()
            do {
                inAppHelper
                    .didUpdate
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] in
                        Task {
                            await self?.reloadReceipt()
                        }
                    }
                    .store(in: &subscriptions)

                if withProducts {
                    let products = try await inAppHelper.fetchProducts(timeout: Constants.shared.iap.productsTimeoutInterval)
                    pp_log(.App.iap, .info, "Available in-app products: \(products.map(\.key))")
                }
            } catch {
                pp_log(.App.iap, .error, "Unable to fetch in-app products: \(error)")
            }
        }
    }

    public func fetchLevelIfNeeded() async {
        guard userLevel == .undefined else {
            return
        }
        if let customUserLevel {
            userLevel = customUserLevel
            pp_log(.App.iap, .info, "App level (custom): \(userLevel)")
            return
        }
        let isBeta = await betaChecker.isBeta()
        guard userLevel == .undefined else {
            return
        }
        userLevel = isBeta ? .beta : .freemium
        pp_log(.App.iap, .info, "App level: \(userLevel)")
    }
}
