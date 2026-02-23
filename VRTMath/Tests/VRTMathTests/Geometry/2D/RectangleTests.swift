//
//  RectangleTests.swift
//  VRTMath
//
//  Created by David Kanenwisher on 2/17/26.
//

import Testing
@testable import VRTMath
typealias Rectangle = VRTM2D.Rectangle

import Foundation

struct RectangleTests {

  @Test func `various constructors`() throws {
    let rectOne = Rectangle(min: F2(0, 0), max: F2(1, 1))
    #expect(rectOne.area == 1.0)

    let rectTwo = Rectangle(x: 0, y: 0, width: 2, height: 2)
    #expect(rectTwo.area == 4.0)

    let rectThree = Rectangle(position: F2(0, 0), radius: 3.0)
    #expect(rectThree.area == 36.0)
  }

  @Test func `height and width`() throws {
    let rectOne = Rectangle(min: F2(0, 0), max: F2(1, 1))
    #expect(rectOne.height == 1.0)
    #expect(rectOne.width == 1.0)
  }

  @Test func whenTwoRectanglesDontIntersect() throws {
    let rectOne = Rectangle(min: F2(0, 0), max: F2(1, 1))
    [
      Rectangle(min: F2(2, 2), max: F2(3, 3)),
      Rectangle(min: F2(-2, 2), max: F2(-1, 3)),
      Rectangle(min: F2(0, 2), max: F2(1, 3)),
      Rectangle(min: F2(0, -2), max: F2(1, -1)),
    ].forEach { rectTwo in
      #expect(rectOne.intersection(with: rectTwo) == nil)
    }
  }

  @Test func whenTwoRectanglesDoIntersect() throws {
    let rectOne = Rectangle(min: F2(0, 0), max: F2(1, 1))
    let rectTwo = Rectangle(min: F2(0.9, 0.9), max: F2(3, 3))

    #expect(rectOne.intersection(with: rectTwo)!.x >= 0.1)
  }

  @Test func testContainsFloat2() {
    let r = Rectangle(min: Float2(0.0, 0.0), max: Float2(5.0, 5.0))

    #expect(r.contains(Float2(6.0, 6.0)) == false)
    #expect(r.contains(Float2(6.0, 4.0)) == false)
    #expect(r.contains(Float2(1.0, 1.0)) == true)
  }

  @Test func testContainsRect() {
    let r = Rectangle(0.0, 0.0, 5.0, 5.0)

    #expect(r.contains(-1.0, -1.0, 1.0, 1.0) == false)  // upper left
    #expect(r.contains(4.0, 1.0, 6.0, -1.0) == false)  // upper right
    #expect(r.contains(-1.0, 4.0, 1.0, 6.0) == false)  // lower left
    #expect(r.contains(4.0, 4.0, 6.0, 6.0) == false)  // lower right

    #expect(r.contains(0.0, 0.0, 3.0, 3.0) == true)
  }

  @Test func `a rectangle can't contain a larger one`() {
    let smaller = Rectangle(0.0, 0.0, 1.0, 1.0)
    let bigger = Rectangle(0.0, 0.0, 5.0, 5.0)

    #expect(smaller.contains(bigger) == false)
  }
}
