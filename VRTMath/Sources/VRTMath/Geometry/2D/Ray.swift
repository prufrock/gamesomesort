//
//  Ray.swift
//  VRTMath
//
//  Created by David Kanenwisher on 3/8/26.
//

public extension VRTM2D {
  struct Ray {
    var origin, direction: F2

    var slopeIntercept: (slope: Float, yIntercept: Float) {
      let slope = direction.y / direction.x
      let yIntercept = origin.y - slope * origin.x
      return (slope, yIntercept)
    }
  }
}
