//
//  Bundle+Extensions.swift
//  Passepartout
//
//  Created by Davide De Rosa on 11/14/24.
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

import Foundation

extension Bundle {
    public func unsafeDecode<T: Decodable>(_ type: T.Type, filename: String) -> T {
        guard let jsonURL = url(forResource: filename, withExtension: "json") else {
            fatalError("Unable to find \(filename).json in bundle")
        }
        do {
            let data = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode(type, from: data)
        } catch {
            fatalError("Unable to decode \(filename).json: \(error)")
        }
    }
}
