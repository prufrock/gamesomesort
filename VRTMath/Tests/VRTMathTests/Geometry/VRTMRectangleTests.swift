//
//  VRTMRectangleTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import Testing
@testable import VRTMath

import Foundation

struct GEORectangleTests {

  @Test func whenTwoRectanglesDontIntersect() throws {
    let rectOne = VRTMRectangle(min: F2(0, 0), max: F2(1, 1))
    let rectTwo = VRTMRectangle(min: F2(2, 2), max: F2(3, 3))

    #expect(rectOne.intersection(with: rectTwo) == nil)
  }

  @Test func whenTwoRectanglesDoIntersect() throws {
    let rectOne = VRTMRectangle(min: F2(0, 0), max: F2(1, 1))
    let rectTwo = VRTMRectangle(min: F2(0.9, 0.9), max: F2(3, 3))

    #expect(rectOne.intersection(with: rectTwo)!.x >= 0.1)
  }

  @Test func testContainsFloat2() {
    let r = VRTMRectangle(min: Float2(0.0, 0.0), max: Float2(5.0, 5.0))

    #expect(r.contains(Float2(6.0, 6.0)) == false)
    #expect(r.contains(Float2(6.0, 4.0)) == false)
    #expect(r.contains(Float2(1.0, 1.0)) == true)
  }

  @Test func testContainsRect() {
    let r = VRTMRectangle(0.0, 0.0, 5.0, 5.0)

    #expect(r.contains(-1.0, -1.0, 1.0, 1.0) == false)  // upper left
    #expect(r.contains(4.0, 1.0, 6.0, -1.0) == false)  // upper right
    #expect(r.contains(-1.0, 4.0, 1.0, 6.0) == false)  // lower left
    #expect(r.contains(4.0, 4.0, 6.0, 6.0) == false)  // lower right

    #expect(r.contains(0.0, 0.0, 3.0, 3.0) == true)
  }
}
