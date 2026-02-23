//
//  VRTMCircle.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/22/26.
//

public extension VRTM2D {
  /// A circle for when you need one.
  struct Circle {
    public private(set) var center: F2
    public private(set) var radius: Float
    public var diameter: Float { 2 * radius }
    public var area: Float { .pi * radius * radius }

    public init(center: F2, radius: Float) {
      self.center = center
      self.radius = radius
    }

    public func intersection(_ other: Circle, delta: Float = 1e-9) -> F2? {
        let dx = other.center.x - center.x
        let dy = other.center.y - center.y

        // Use the squared distance to avoid a square root.
        let distanceSquared = dx * dx + dy * dy
        let radiusSum = radius + other.radius

        // There's no collision, when the distance is greater than or equal to the sum of the radii.
        if distanceSquared >= radiusSum * radiusSum {
            return nil
        }

        // Vector pointing from one radii to the other.
        let displacement = F2(dx, dy)
        // Need the actual distance to find the amount of overlap, so get the root.
        let distance = distanceSquared.squareRoot()
        let overlap = radiusSum - distance

        // Find the normalized direction vector.
        let direction: F2
        if distance > 0 {
          direction = displacement / distance
        } else {
          direction = F2(x: 1, y: 0) // Default, if overlapping
        }

        return overlap * direction
    }
  }
}

