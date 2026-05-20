//
//  TBDGWorldTests.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/28/26.
//

import DataStructures
import Foundation
import GameConfiguration
import lecs_swift
import LECSPieces
import Testing
import VRTMath
@testable import TileBasedGame


@Test func `change the screen dimensions`() {
  let world = startWorld()

  world.update(VRTMScreenDimensions(
    pixelSize: CGSize(width: 300, height: 500),
    scaleFactor: 1.0)
  )

  _ = {
    let entity = world.ecs.entity("playerCamera")!

    let aspect = world.ecs.getComponent(
      entity,
      LECSPAspect.self
    )!
    #expect(aspect == 0.6)
  }()

  _ = {
    let entity = world.ecs.entity("exitButton")

    #expect(entity != nil)
  }()
}

@Test func `exit the world`() {
  let world = startWorld()

  world.update(VRTMScreenDimensions(
    pixelSize: CGSize(width: 500, height: 500),
    scaleFactor: 1.0)
  )

  var events = DSQueueArray<TBDGame.Input.Events>()
  events.enqueue(.tap(tapLocation: F2(175.0, 65.0), lastTapTime: 0.009))
  let input = TBDGame.Input(events: events)

  var commands = world.update(
    timeStep: 0.01, input: input
  )

  #expect(commands.dequeue() == .start(level: 0))
}

private func startWorld() -> TBDGWorld {
  let worldCfg = GCFGWorld(
    entities: GCFGEntities(
      creatures: [:],
      things: [:],
      tiles: [
        0: GCFGTile(
          color: [0.5, 0.5, 0.5],
          model: "button-one",
          name: "floor",
          radius: 0.5,
          rotationDegY: 0,
          scale: 0.95,
          tappable: true,
          visible: true,
          z: 1.0
        )
      ]
    ),
    hud: GCFGWorld.HUD(
      buttons: [
        GCFGWorld.HUD
          .Button(
            behaviors: ["exit"],
            color: [0, 0, 0],
            name: "exitButton",
            model: "square",
            position: [1.0, -2, 1.0],
            radius: 1.5,
            rotationDegrees: 0,
            tappable: true,
            visible: true
          )
      ],
      input: GCFGWorld.HUD.Input(
        tap: GCFGWorld.HUD.Input.Tap(radius: 1.0)
      )
    ),
    levels: [
      "world_one_level_001": GCFGWorld.LevelPath(
        name: "world one level 001", 
        path: "world_one_level_001"
      )
    ],
    name: "world_one_level",
    worldVector: [1, -1, 1]
  )

  let levelOneCfg: GCFGLevel = GCFGLevel(
    map: GCFGLevel.Map(
      creatures: [
        0, 0,
        0, 0
      ],
      things: [
        0, 0,
        0, 0
      ],
      tiles: [
        0, 0,
        0, 0
      ],
      width: 2,
    ),
    playerCamera: GCFGLevel.Camera(
      farPlane: 10.0,
      nearPlane: 0.1,
      position: [3.5, 4, -7.25],
      viewAngleDegrees: 90.0,
    ),
    sun: GCFGLevel.Light.Sun(
      color: [1, 1, 1],
      position: [0, 0, -9],
    )
  )

  let ecs = LECSCreateWorld(archetypeSize: 100)

  let world = TBDGWorld(
    worldConfig: worldCfg,
    levelConfig: levelOneCfg,
    ecs: ecs
  )

  world.restart()

  return world
}
