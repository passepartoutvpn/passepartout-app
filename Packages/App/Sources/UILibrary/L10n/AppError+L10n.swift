//
//  AppError+L10n.swift
//  Passepartout
//
//  Created by Davide De Rosa on 8/27/24.
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
import Foundation
import PassepartoutKit

extension AppError: LocalizedError {
    public var errorDescription: String? {
        let V = Strings.Errors.App.self
        switch self {
        case .couldNotLaunch(let reason):
            return reason.localizedDescription

        case .emptyProducts:
            return V.emptyProducts

        case .emptyProfileName:
            return V.emptyProfileName

        case .ineligibleProfile:
            return nil

        case .interactiveLogin:
            return nil

        case .malformedModule(let module, let error):
            return V.malformedModule(module.moduleType.localizedDescription, error.localizedDescription)

        case .permissionDenied:
            return V.permissionDenied

        case .generic(let error):
            return error.localizedDescription
        }
    }
}

extension TaskTimeoutError: PassepartoutErrorMappable {
    public var asPassepartoutError: PassepartoutError {
        PassepartoutError(.timeout)
    }
}

// MARK: - App side

extension PassepartoutError: @retroactive LocalizedError {
    public var errorDescription: String? {
        switch code {
        case .connectionModuleRequired:
            return Strings.Errors.App.Passepartout.connectionModuleRequired

        case .corruptProviderModule:
            return Strings.Errors.App.Passepartout.corruptProviderModule(reason?.localizedDescription ?? "")

        case .incompatibleModules:
            return Strings.Errors.App.Passepartout.incompatibleModules

        case .invalidFields:
            let fields = (userInfo as? [String: String?])
                .map {
                    $0.map {
                        "\($0)=\($1?.description ?? "")"
                    }
                    .joined(separator: ",")
                }

            return [Strings.Errors.App.Passepartout.invalidFields, fields]
                .compactMap { $0 }
                .joined(separator: " ")

        case .missingProviderEntity:
            return Strings.Errors.App.Passepartout.missingProviderEntity

        case .noActiveModules:
            return Strings.Errors.App.Passepartout.noActiveModules

        case .parsing:
            let message = userInfo as? String ?? (reason as? LocalizedError)?.localizedDescription

            return [Strings.Errors.App.Passepartout.parsing, message]
                .compactMap { $0 }
                .joined(separator: " ")

        case .providerRequired:
            return Strings.Errors.App.Passepartout.providerRequired

        case .timeout:
            return Strings.Errors.App.Passepartout.timeout

        case .unhandled:
            return reason?.localizedDescription

        default:
            return Strings.Errors.App.Passepartout.default(code.rawValue)
        }
    }
}

// MARK: - Tunnel side

extension PassepartoutError.Code: StyledLocalizableEntity {
    public enum Style {
        case tunnel
    }

    public func localizedDescription(style: Style) -> String {
        switch style {
        case .tunnel:
            let V = Strings.Errors.Tunnel.self
            switch self {
            case .App.ineligibleProfile:
                return V.ineligible

            case .authentication:
                return V.auth

            case .crypto:
                return V.encryption

            case .dnsFailure:
                return V.dns

            case .timeout:
                return Strings.Global.Nouns.timeout

            case .OpenVPN.compressionMismatch:
                return V.compression

            case .OpenVPN.noRouting:
                return V.routing

            case .OpenVPN.serverShutdown:
                return V.shutdown

            case .OpenVPN.tlsFailure:
                return V.tls

            default:
                return V.generic
            }
        }
    }
}
