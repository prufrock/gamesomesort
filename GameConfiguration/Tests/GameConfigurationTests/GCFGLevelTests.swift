//
//  GCFGWorldTests.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

import Testing
@testable import GameConfiguration

import Foundation

@Test func `create level with no map`() async throws {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/TestLevels/level_no_map",
    withExtension: "json"
  )!

  let data: Data = try! Data(contentsOf: jsonUrl)
  let world: GCFGLevel = try! JSONDecoder().decode(
    GCFGLevel.self,
    from: data
  )

  #expect(world.name == "level no map")
}
