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
  let level: GCFGLevel = try! loadTestLevel(name: "level_no_map")

  #expect(level.name == "level no map")
  #expect(level.tiles.count == 0)
}

@Test func `create level empty 2x2`() async throws {
  let level: GCFGLevel = try! loadTestLevel(name: "level_empty_2x2")

  #expect(level.name == "level empty 2x2")
  #expect(level.tiles.count == 4)
  level.tiles.forEach { tile in
    #expect(tile == 0)
  }
  #expect(level.creatures.count == 4)
  level.creatures.forEach { creature in
    #expect(creature == 0)
  }
}

private func loadTestLevel(name: String) throws -> GCFGLevel {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/TestLevels/\(name)",
    withExtension: "json"
  )!
  
  let data: Data = try! Data(contentsOf: jsonUrl)
  return try JSONDecoder().decode(GCFGLevel.self, from: data)
}
