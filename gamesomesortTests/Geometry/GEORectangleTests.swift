//
//  GEORectangleTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

import Testing
@testable import gamesomesort

import Foundation

struct GEORectangleTests {

  @Test func whenTwoRectanglesDontIntersect() throws {
    let rectOne = GEORectangle(min: F2(0, 0), max: F2(1, 1))
    let rectTwo = GEORectangle(min: F2(2, 2), max: F2(3, 3))

    #expect(rectOne.intersection(with: rectTwo) == nil)
  }

  @Test func whenTwoRectanglesDoIntersect() throws {
    let rectOne = GEORectangle(min: F2(0, 0), max: F2(1, 1))
    let rectTwo = GEORectangle(min: F2(0.9, 0.9), max: F2(3, 3))

    #expect(rectOne.intersection(with: rectTwo)!.x >= 0.1)
  }
}
