//
//  GCFGWorldTests.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

import Testing
@testable import GameConfiguration

import Foundation

@Test func `create world with no levels`() async throws {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/TestWorlds/world_no_levels",
    withExtension: "json"
  )!

  let data: Data = try! Data(contentsOf: jsonUrl)
  let world: GCFGWorld = try! JSONDecoder().decode(GCFGWorld.self, from: data)

  #expect(world.name == "no levels")
  #expect(world.levels.count == 0)
}
