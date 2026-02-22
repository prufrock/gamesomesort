//
//  VRTRectangle.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

/// A rectangle for all your rectangle needs.
public struct VRTMRectangle {
  /// The smallest and largest corners of the rectangle.
  public var min, max: F2

  /// The area of the rectangle.
  public var area: Float {
    get {
      height * width
    }
  }

  /// The difference between the largest and smallest corner on the y-axis.
  public var height: Float {
    get {
      max.y - min.y
    }
  }

  /// The difference between the largest and smallest corner on the x-axis.
  public var width: Float {
    get {
      max.x - min.x
    }
  }

  private var corners: [F2] {
    get {
      [F2(min.x, min.y), F2(min.x, max.y), F2(max.x, max.y), F2(max.x, min.y)]
    }
  }

  /// Create a rectangle from the smallest and largest points.
  public init(min: F2, max: F2) {
    self.min = min
    self.max = max
  }

  /// Create a rectangle from the smallest and largest points.
  public init(_ minX: Float, _ minY: Float, _ maxX: Float, _ maxY: Float) {
    min = F2(minX, minY)
    max = F2(maxX, maxY)
  }

  /// Create a rectangle at x, y by adding x + width and y + height.
  public init(x: Float, y: Float, width: Float, height: Float) {
    self.min = F2(x, y)
    self.max = F2(x + width, y + height)
  }

  /// Create a square rectangle centered on a point.
  public init(position: F2, radius: Float = 1) {
    self.min = position - F2(x: radius, y: radius)
    self.max = position + F2(x: radius, y: radius)
  }

  /// Check for intersection between two rectangles, returning the smallest
  /// intersection.
  public func intersection(with rect: Self) -> F2? {
    let left = F2(x: max.x - rect.min.x, y: 0)
    if left.x <= 0 {
      return nil
    }
    let right = F2(x: min.x - rect.max.x, y: 0)
    if right.x >= 0 {
      return nil
    }
    let up = F2(x: 0, y: max.y - rect.min.y)
    if up.y <= 0 {
      return nil
    }
    let down = F2(x: 0, y: min.y - rect.max.y)
    if down.y >= 0 {
      return nil
    }

    // sort by length with the smallest first and grab that one
    return [left, right, up, down].sorted(by: { $0.length < $1.length }).first
  }

  /// Whether a rectangle is within this rectangle.
  public func contains(_ rect: Self) -> Bool {
    // This can't contain the rectangle if it's not big enough
    if area < rect.area {
      return false
    }

    // All 4 corners must be inside this rectangle.
    return rect.corners.filter { contains($0) }.count == 4
  }

  /// Whether the 4 points of a rectangle are all inside this rectangle.
  public func contains(
    _ minX: Float,
    _ maxX: Float,
    _ minY: Float,
    _ maxY: Float
  ) -> Bool {
    contains(Self.init(minX, maxX, minY, maxY))
  }

  /// Whether a single float is within this rectangle.
  public func contains(_ p: Float2) -> Bool {
    !(min.x > p.x || max.x < p.x || min.y > p.y || max.y < p.y)
  }
}
