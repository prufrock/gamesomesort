//
//  DSQueue.swift
//  DataStructures
//
//  Created by David Kanenwisher on 2/5/26.
//

/// All the basic functionality you want in a queue.
public protocol DSQueue<T>: CustomStringConvertible {
  associatedtype T

  var isEmpty: Bool { get }

  var count: Int { get }

  /// Add an element at the back of the queue.
  @discardableResult
  mutating func enqueue(_ item: T) -> Bool

  /// Remove an element from the front of the queue.
  mutating func dequeue() -> T?

  /// Return the element at the front of the queue without removing it.
  func peek() -> T?

  /// Return the elements of the queue as an array.
  func toArray() -> [T]
}
