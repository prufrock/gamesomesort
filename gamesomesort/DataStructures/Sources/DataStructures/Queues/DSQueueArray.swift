//
//  DSQueueArray.swift
//  DataStructures
//
//  Created by David Kanenwisher on 2/5/26.
//

/// A queue based on an array.
public struct DSQueueArray<T>: DSQueue {

  public var description: String {
    storage.map { "\($0)" }.joined(separator: ", ")
  }

  private var storage: [T] = []

  public init(storage: [T] = []) {
    self.storage = storage
  }

  public init() {
    self.storage = []
  }

  public var count: Int {
    storage.count
  }

  public var isEmpty: Bool {
    storage.isEmpty
  }

  @discardableResult
  public mutating func enqueue(_ item: T) -> Bool {
    storage.append(item)
    return true
  }

  public mutating func dequeue() -> T? {
    guard !isEmpty else {
      return nil
    }

    return storage.removeFirst()
  }

  public func peek() -> T? {
    storage.first
  }

  public func toArray() -> [T] {
    storage
  }
}
