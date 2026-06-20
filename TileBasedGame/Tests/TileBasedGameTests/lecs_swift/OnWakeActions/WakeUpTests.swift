//
//  WakeUpTests.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/19/26.
//

import GameConfiguration
import lecs_swift
import LECSPieces
import Testing
@testable import TileBasedGame

@Suite
struct WakeUpTests {
  private let ecs: LECSWorld
  private let worldCfg: GCFGWorld

  init() {
    let helpers = TestHelpers()
    ecs = LECSCreateWorld(archetypeSize: 100)
    worldCfg = helpers.worldCfg
    helpers.initComponents(ecs: ecs)
  }

  @Test func `when no onWake behaviors no changes`() {
    let sourceId = ecs.createEntity("sourceEntity")
    let onWake = LECSPOnWake()

    onWake.wakeUp(id: LECSId(sourceId), ecs: ecs, worldCfg: worldCfg)
  }
}
