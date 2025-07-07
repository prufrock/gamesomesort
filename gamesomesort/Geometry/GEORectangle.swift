//
//  GEORectangle.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

struct GEORectangle {
  var min, max: F2

  var area: Float {
    get {
      height * width
    }
  }

  var height: Float {
    get {
      max.y - min.y
    }
  }

  var width: Float {
    get {
      max.x - min.x
    }
  }

  private var corners: [F2] {
    get {
      [F2(min.x, min.y), F2(min.x, max.y), F2(max.x, max.y), F2(max.x, min.y)]
    }
  }

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

  init(position: F2, radius: Float = 1) {
    self.min = position - F2(x: radius, y: radius)
    self.max = position + F2(x: radius, y: radius)
  }

  func intersection(with rect: Self) -> F2? {
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

  func contains(_ rect: Self) -> Bool {
    // This can't contain the rectangle if it's not big enough
    if area < rect.area {
      return false
    }

    // All 4 corners must be inside this rectangle.
    return rect.corners.filter { contains($0) }.count == 4
  }

  func contains(_ minX: Float, _ maxX: Float, _ minY: Float, _ maxY: Float) -> Bool {
    contains(Self.init(minX, maxX, minY, maxY))
  }

  func contains(_ p: Float2) -> Bool {
    !(min.x > p.x || max.x < p.x || min.y > p.y || max.y < p.y)
  }
}
