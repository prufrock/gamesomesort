//
//  GeometryContantsTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 5/24/26.
//

import Testing
@testable import VRTMath
import Numerics

@Test func `degrees to radians`() throws {
  #expect((180 * DEG2RAD).isClose(to: 🥧))
  #expect((90 * DEG2RAD).isClose(to: 🥧/2))
}
