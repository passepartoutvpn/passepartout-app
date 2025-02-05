//
//  TaskTimeout.swift
//  Passepartout
//
//  Created by Davide De Rosa on 2/3/25.
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

public struct TaskTimeoutError: Error {
}

public func performTask<T>(withTimeout timeout: Int, taskBlock: @escaping () async throws -> T) async throws -> T {
    let task = Task {
        let taskResult = try await taskBlock()
        try Task.checkCancellation()
        return taskResult
    }
    let timeoutTask = Task {
        try await Task.sleep(for: .seconds(timeout))
        task.cancel()
    }
    do {
        let result = try await task.value
        timeoutTask.cancel()
        return result
    } catch {
        throw TaskTimeoutError()
    }
}
