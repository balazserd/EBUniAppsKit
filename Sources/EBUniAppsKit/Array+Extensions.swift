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
    /// - Parameter mapBlock: The async operation to perform on each element in the array.
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
    
    /// Concurrently performs an operation for each element of an array.
    ///
    /// - Parameter maxConcurrencyCount: The number of maximum possible concurrent processing the `ThrowingTaskGroup` should handle.
    /// - Parameter block: The async operation to perform for each element in the array.
    ///
    /// The underlying implementation uses a ``Swift.ThrowingTaskGroup``.
    func forEachAsync(maxConcurrencyCount: Int = .max,
                      _ block: @escaping (Self.Element) async throws -> Void)
    async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for index in 0..<Swift.min(maxConcurrencyCount, self.count) {
                group.addTask {
                    try await block(self[index])
                }
            }
            
            var nextIndex = maxConcurrencyCount
            while let nextElement = try await group.next() {
                if nextIndex < self.count {
                    group.addTask { [nextIndex] in
                        try await block(self[nextIndex])
                    }
                }
                
                nextIndex += 1
            }
        }
    }
    
    /// Concurrently processes the elements of an array, then performs an operation with the results serially, preserving the original array's order.
    ///
    /// - Parameter maxConcurrencyCount: The number of maximum possible concurrent processing the `ThrowingTaskGroup` should handle.
    /// - Parameter mapBlock: The async operation to map each element in the array.
    /// - Parameter serialPerformBlock: The async operation to perform on each mapped element, in the order of the original array.
    ///
    /// The underlying implementation uses a ``Swift.ThrowingTaskGroup``.
    ///
    /// This function is useful when the last part of an expensive operation must be performed serially, but inputs for the serial part can be obtained concurrently.
    ///
    /// The process will maintain an input result buffer, always waiting for the next-in-order input to be received but starting new mapping blocks if later input results arrive earlier - up until the concurrency limit.
    ///
    /// The following errors can be thrown:
    /// | Code | Description                      |
    /// | ---- | -------------------------------- |
    /// | -1   | The buffer element is not found. |
    func mapConcurrentlyThenPerformSeriallyAsync<M>(maxConcurrencyCount: Int = .max,
                                                    mapPriority: TaskPriority = .medium,
                                                    mapBlock: @escaping @Sendable (Self.Element) async throws -> M,
                                                    serialPerformBlock: @escaping @Sendable (M) async throws -> Void)
    async throws where M: Sendable, Self.Element: Sendable {
        try await withThrowingTaskGroup(of: (Int, M).self) { group in
            for index in 0..<Swift.min(maxConcurrencyCount, self.count) {
                group.addTask(priority: mapPriority) {
                    return try await (index, mapBlock(self[index]))
                }
            }
            
            var nextTaskIndex = maxConcurrencyCount
            var buffer = [(Int, M)]()
            for nextResultIndex in 0..<self.count {
                repeat {
                    guard let (newResultIndex, newResult) = try await group.next() else { break }
                    buffer.append((newResultIndex, newResult))
                    
                    if nextTaskIndex < self.count {
                        group.addTask(priority: mapPriority) { [nextTaskIndex] in
                            return try await (nextTaskIndex, mapBlock(self[nextTaskIndex]))
                        }
                    }
                    
                    nextTaskIndex += 1
                } while buffer.first(where: { $0.0 == nextResultIndex }) == nil
                
                guard let nextResultBufferIndex = buffer.firstIndex(where: { $0.0 == nextResultIndex }) else {
                    throw NSError(domain: "EBUniAppsKit", code: -1, userInfo: ["Description": "The next result buffer index is not found."])
                }
                
                try await serialPerformBlock(buffer[nextResultBufferIndex].1)
                buffer.remove(at: nextResultBufferIndex)
            }
        }
    }
}
