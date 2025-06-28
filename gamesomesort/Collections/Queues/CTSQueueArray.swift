//
//  CTSQueueArray.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/27/25.
//

/// A queue based on an array.
struct CTSQueueArray<T>: CTSQueue {
  var description: String {
    storage.map { "\($0)" }.joined(separator: ", ")
  }

  private var storage: [T] = []

  var count: Int {
    storage.count
  }

  var isEmpty: Bool {
    storage.isEmpty
  }

  @discardableResult
  mutating func enqueue(_ item: T) -> Bool {
    storage.append(item)
    return true
  }

  mutating func dequeue() -> T? {
    guard !isEmpty else {
      return nil
    }

    return storage.removeFirst()
  }

  func peek() -> T? {
    storage.first
  }

  func toArray() -> [T] {
    storage
  }
}
