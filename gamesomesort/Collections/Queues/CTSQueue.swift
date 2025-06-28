//
//  CTSQueue.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/27/25.
//

/// All the basic functionality you want in a queue.
protocol CTSQueue<T>: CustomStringConvertible, ScopeFunction {
  associatedtype T

  var isEmpty: Bool { get }

  var count: Int { get }

  /// Add an element at the back of the queue.
  mutating func enqueue(_ item: T) -> Bool

  /// Remove an element from the front of the queue.
  mutating func dequeue() -> T?

  /// Return the element at the front of the queue without removing it.
  func peek() -> T?

  /// Return the elements of the queue as an array.
  func toArray() -> [T]
}
