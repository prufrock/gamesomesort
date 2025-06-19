//
//  GEORectangle.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

struct GEORectangle {
  var min, max: F2

  init(min: F2, max: F2) {
    self.min = min
    self.max = max
  }

  init(x: Float, y: Float, width: Float, height: Float) {
    self.min = F2(x, y)
    self.max = F2(x + width, y + height)
  }

  init(_ minX: Float, _ minY: Float, _ maxX: Float, _ maxY: Float) {
    min = F2(minX, minY)
    max = F2(maxX, maxY)
  }

  func intersection(with rect: GEORectangle) -> F2? {
    let left = F2(x: max.x - rect.min.x, y: 0)  // world
    if left.x <= 0 {
      return nil
    }
    let right = F2(x: min.x - rect.max.x, y: 0)  // world
    if right.x >= 0 {
      return nil
    }
    let up = F2(x: 0, y: max.y - rect.min.y)  // world
    if up.y <= 0 {
      return nil
    }
    let down = F2(x: 0, y: min.y - rect.max.y)  // world
    if down.y >= 0 {
      return nil
    }

    // sort by length with the smallest first and grab that one
    return [left, right, up, down].sorted(by: { $0.length < $1.length }).first
  }
}
