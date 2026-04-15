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

private func loadTestFile<T: Decodable>(from dir: String, name: String) throws -> T {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/TestWorlds/\(dir)/\(name)",
    withExtension: "json"
  )!

  let data: Data = try! Data(contentsOf: jsonUrl)
  return try JSONDecoder().decode(T.self, from: data)
}
