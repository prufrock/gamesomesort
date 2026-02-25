//
//  VRTMCircleTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/22/26.
//

import Testing
@testable import VRTMath
typealias Circle = VRTM2D.Circle
import Numerics

struct CircleTests {

  @Test func `various constructors`() throws {
    let circleOne = Circle(center: F2(0, 0), radius: 1.0)
    #expect(circleOne.area == .pi)
  }

  @Test func `when circles intersect circles, or doesn't`() throws {
    let circle = Circle(center: F2(0, 0), radius: 1.0)

    #expect(
      circle.intersection(circle) == F2(2.0,0),
      "the circles entirely overlap"
    )

    let circleRightHalf = Circle(center: F2(1, 0), radius: 1.0)
    #expect(
      circle.intersection(circleRightHalf) == F2(1.0,0),
      "the other circle overlaps the right half of the circle"
    )

    let circleUpperQuarter = Circle(center: F2(1, 1), radius: 1.0)
    let upperQuarterResult = circle.intersection(circleUpperQuarter)
    #expect(
      upperQuarterResult!.isClose(
        to: F2(0.414, 0.414),
        absoluteTolerance: 0.001
      ),
      "the other circle overlaps the upper right quarter of the circle"
    )

    let circleDoesntIntersect = Circle(center: F2(2,2), radius: 1.0)
    #expect(
      circle.intersection(circleDoesntIntersect) == nil,
      "the circle shouldn't intersect"
    )
  }
}
