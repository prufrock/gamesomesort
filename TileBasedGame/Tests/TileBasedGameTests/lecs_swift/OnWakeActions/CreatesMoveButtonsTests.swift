//
//  CreatesButtons.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/20/26.
//

import GameConfiguration
import lecs_swift
import LECSPieces
import Testing
@testable import TileBasedGame

@Suite
struct CreatesMoveButtonsTests {
  private let ecs: LECSWorld
  private let worldCfg: GCFGWorld

  init() {
    let helpers = TestHelpers()
    ecs = LECSCreateWorld(archetypeSize: 100)
    worldCfg = helpers.worldCfg
    helpers.initComponents(ecs: ecs)
  }
}
