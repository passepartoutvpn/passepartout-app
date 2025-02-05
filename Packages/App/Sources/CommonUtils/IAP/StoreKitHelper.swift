//
//  StoreKitHelper.swift
//  Passepartout
//
//  Created by Davide De Rosa on 9/9/24.
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
import Foundation
import StoreKit

@MainActor
public final class StoreKitHelper<ProductType>: InAppHelper where ProductType: RawRepresentable & Hashable,
                                                                  ProductType.RawValue == String {

    private let products: [ProductType]

    private let inAppIdentifier: (ProductType) -> String

    private var activeTransactions: Set<Transaction>

    private nonisolated let didUpdateSubject: PassthroughSubject<Void, Never>

    private var observer: Task<Void, Never>?

    public init(products: [ProductType], inAppIdentifier: @escaping (ProductType) -> String) {
        self.products = products
        self.inAppIdentifier = inAppIdentifier
        activeTransactions = []
        didUpdateSubject = PassthroughSubject()

        observer = transactionsObserverTask()
    }

    deinit {
        observer?.cancel()
    }
}

extension StoreKitHelper {
    public nonisolated var canMakePurchases: Bool {
        AppStore.canMakePayments
    }

    public nonisolated var didUpdate: AnyPublisher<Void, Never> {
        didUpdateSubject.eraseToAnyPublisher()
    }

    public func fetchProducts(timeout: Int) async throws -> [ProductType: InAppProduct] {
        let skProducts = try await performTask(withTimeout: timeout) {
            try await Product.products(for: self.products.map(self.inAppIdentifier))
        }
        return skProducts.reduce(into: [:]) {
            guard let pid = ProductType(rawValue: $1.id) else {
                return
            }
            $0[pid] = InAppProduct(
                productIdentifier: $1.id,
                localizedTitle: $1.displayName,
                localizedPrice: $1.displayPrice,
                native: $1
            )
        }
    }

    public func purchase(_ inAppProduct: InAppProduct) async throws -> InAppPurchaseResult {
        guard let skProduct = inAppProduct.native as? Product else {
            return .notFound
        }
        switch try await skProduct.purchase() {
        case .success(let verificationResult):
            guard let transaction = try? verificationResult.payloadValue else {
                break
            }
            activeTransactions.insert(transaction)
            didUpdateSubject.send()
            await transaction.finish()
            return .done

        case .pending:
            return .pending

        case .userCancelled:
            break

        @unknown default:
            break
        }
        return .cancelled
    }

    public func restorePurchases() async throws {
        try await AppStore.sync()
    }
}

private extension StoreKitHelper {
    nonisolated func transactionsObserverTask() -> Task<Void, Never> {
        Task {
            for await update in Transaction.updates {
                guard let transaction = try? update.payloadValue else {
                    continue
                }
                await fetchActiveTransactions()
                await transaction.finish()
                guard !Task.isCancelled else {
                    break
                }
            }
        }
    }

    func fetchActiveTransactions() async {
        var activeTransactions: Set<Transaction> = []
        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? entitlement.payloadValue {
                activeTransactions.insert(transaction)
            }
        }
        self.activeTransactions = activeTransactions
        didUpdateSubject.send()
    }
}
