//
//  RayTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 3/8/26.
//

import Testing
@testable import VRTMath
typealias Ray = VRTM2D.Ray
import Numerics

struct RayTests {

  @Test func `various constructors`() throws {
    let rayOriginDirection = Ray(origin: F2(0,0), direction: F2(1,0))
    #expect(rayOriginDirection.slopeIntercept.0 == 0)
  }

  @Test func `non-zero slope intercept`() throws {
    let rayNonZeroSlopeIntercept = Ray(
      origin: F2(0,0),
      direction: F2(1,1))
    #expect(rayNonZeroSlopeIntercept.slopeIntercept.0 == 1)
    #expect(rayNonZeroSlopeIntercept.slopeIntercept.1 == 0)
  }
}
