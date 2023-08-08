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
    /// - Parameter group: The `ThrowingTaskGroup` which will handle the concurrent async processing of elements.
    /// - Parameter maxConcurrencyCount: The number of maximum possible concurrent processing the `ThrowingTaskGroup` should handle.
    /// - Parameter processBlock: The async operation to perform on each element in the array.
    func mapAsync<T, Failure: Error>(in group: inout ThrowingTaskGroup<T, Failure>,
                                     maxConcurrencyCount: Int = .max,
                                     _ processBlock: @escaping (Self.Element) async throws -> T) async throws -> [T] {
        var returnArray = [T]()
        
        for index in 0..<Swift.min(maxConcurrencyCount, self.count) {
            group.addTask {
                return try await processBlock(self[index])
            }
        }
        
        var nextIndex = maxConcurrencyCount
        while let nextElement = try await group.next() {
            if nextIndex < self.count {
                group.addTask { [nextIndex] in
                    return try await processBlock(self[nextIndex])
                }
            }
            
            nextIndex += 1
            returnArray.append(nextElement)
        }
        
        return returnArray
    }
}
