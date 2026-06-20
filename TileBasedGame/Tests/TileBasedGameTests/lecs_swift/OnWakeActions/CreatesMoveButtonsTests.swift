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

  @Test func `creates a button relative to the source position`() {
    let sourceId = ecs.createEntity("sourceEntity")
    let sourcePos = LECSPPosition3d([1 , 2, 3])
    ecs.addComponent(sourceId, sourcePos)

    let thingCfg = worldCfg[thing: 2]!

    LECSPOnWake.createsMoveButtons(
      id: LECSId(sourceId),
      buttons: [thingCfg],
      ecs: ecs
    )

    var pos: LECSPPosition3d? = nil
    ecs.select([LECSName.self, LECSPPosition3d.self]) { rows, columns in
      let count = counter()
      let name = rows.component(at: count(), columns, LECSName.self)
      if name.name.hasPrefix("thing-\(thingCfg.type)") {
        pos = rows.component(at: count(), columns, LECSPPosition3d.self)
      }    }
    #expect(pos!.position.isClose(to: sourcePos.position + thingCfg.position))
  }
}
