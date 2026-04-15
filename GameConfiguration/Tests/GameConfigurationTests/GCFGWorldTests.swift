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
  let world: GCFGWorld = try! loadTestFile(
    from: "WorldNoLevels",
    name: "world_no_levels"
  )

  #expect(world.name == "no levels")
  #expect(world.levels.count == 0)
}

@Test func `create world with one level`() async throws {
  let world: GCFGWorld = try! loadTestFile(
    from: "WorldOneLevel",
    name: "world_one_level"
  )

  let levelOne: GCFGLevel = try! loadTestFile(
    from: "WorldOneLevel",
    name: world.levels["world_one_level_001"]!.path
  )

  #expect(world.entities.creatures.count == 1)
  #expect(levelOne.entities.creatures.count == 1)
}

private func loadTestFile<T: Decodable>(from dir: String, name: String) throws -> T {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/TestWorlds/\(dir)/\(name)",
    withExtension: "json"
  )!

  let data: Data = try! Data(contentsOf: jsonUrl)
  return try JSONDecoder().decode(T.self, from: data)
}
