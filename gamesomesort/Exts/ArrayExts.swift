//
//  ArrayExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/16/25.
//

extension Array {
  func chunked(into size: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: size).map {
      Array(self[$0..<Swift.min($0 + size, count)])
    }
  }

  func forEachIndexed(_ body: (Int, Element) throws -> Void) rethrows {
    for (index, item) in self.enumerated() {
      try body(index, item)
    }
  }
}
