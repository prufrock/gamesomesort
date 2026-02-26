//
//  Float4x4ProjectionTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/25/26.
//

import Testing
@testable import VRTMath
import Numerics
import simd

struct Float4x4ProjectionTests {

  @Test func `perspective projection`() throws {
    let projection = Float4x4.perspectiveProjection(
      fov: .pi / 2,
      aspect: 1.0,
      nearPlane: 1.0,
      farPlane: 3.0
    )
    let expected = Float4x4([
      Float4(1.0, 0.0, 0.0, 0.0),
      Float4(0.0, 1.0, 0.0, 0.0),
      Float4(0.0, 0.0, -1.5, -1.0),
      Float4(0.0, 0.0, -1.5, 0.0),
    ])
    #expect(projection.isClose(to: expected))

    let result = projection * Float4(0.0, 0.0, -2.0, 1.0)
    #expect(result.isClose(to: Float4(0.0, 0.0, 1.5, 2.0)))
    #expect(result.perspectiveDivide.isClose(to: Float3(0.0, 0.0, 0.75)))
  }
}
