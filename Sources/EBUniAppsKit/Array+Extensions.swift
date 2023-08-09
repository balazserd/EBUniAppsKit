//
//  Array+Extensions.swift
//  
//
//  Created by Balázs Erdész on 2023. 08. 08..
//

import Foundation

public extension Array {
    /// Concurrently processes the elements of an array.
    ///
    /// - Parameter maxConcurrencyCount: The number of maximum possible concurrent processing the `ThrowingTaskGroup` should handle.
    /// - Parameter processBlock: The async operation to perform on each element in the array.
    ///
    /// The underlying implementation uses a ``Swift.ThrowingTaskGroup``.
    func mapAsync<T>(maxConcurrencyCount: Int = .max,
                     _ mapBlock: @escaping (Self.Element) async throws -> T)
    async throws -> [T] {
        try await withThrowingTaskGroup(of: T.self) { group in
            var returnArray = [T]()
            
            for index in 0..<Swift.min(maxConcurrencyCount, self.count) {
                group.addTask {
                    return try await mapBlock(self[index])
                }
            }
            
            var nextIndex = maxConcurrencyCount
            while let nextElement = try await group.next() {
                if nextIndex < self.count {
                    group.addTask { [nextIndex] in
                        return try await mapBlock(self[nextIndex])
                    }
                }
                
                nextIndex += 1
                returnArray.append(nextElement)
            }
            
            return returnArray
        }
    }
}
