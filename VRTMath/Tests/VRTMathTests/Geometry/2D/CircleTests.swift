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

  @Test func `when circles intersect circles`() throws {
    let circleOne = Circle(center: F2(0, 0), radius: 1.0)

    #expect(
      circleOne.intersection(circleOne) == F2(2.0,0),
      "the circles entirely overlap"
    )

    let circleTwo = Circle(center: F2(1, 0), radius: 1.0)
    #expect(
      circleOne.intersection(circleTwo) == F2(1.0,0),
      "the other circle overlaps the right half of the circle"
    )

    let circleThree = Circle(center: F2(1, 1), radius: 1.0)
    let upperQuarterResult = circleOne.intersection(circleThree)
    #expect(
      upperQuarterResult!.isClose(
        to: F2(0.414, 0.414),
        absoluteTolerance: 0.001
      ),
      "the other circle overlaps the upper right quarter of the circle"
    )
  }
}
