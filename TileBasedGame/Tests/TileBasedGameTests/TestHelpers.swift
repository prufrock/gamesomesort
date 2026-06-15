//
//  TestHelpers.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/14/26.
//

import GameConfiguration


struct TestHelpers {
  let worldCfg = GCFGWorld(
    entities: GCFGEntities(
      creatures: [:],
      things: [
        0: GCFGThing(
          color: [0.0, 0.0, 0.0],
          model: "",
          onWake: [],
          position: [0.0, 0.0, 1.0],
          radius: 0.0,
          rotationDegY: 0,
          scale: 0.0,
          tappable: false,
          type: .nothing,
          visible: false,
        ),
        1: GCFGThing(
          color: [0.3, 0.0, 0.9],
          model: "",
          onWake: [.creates(creatureId: "1")],
          position: [0.0, 0.0, 1.0],
          radius: 0.5,
          rotationDegY: 0,
          scale: 0.0,
          tappable: false,
          type: .playerStart,
          visible: false,
        )
      ],
      tiles: [
        0: GCFGTile(
          color: [0.5, 0.5, 0.5],
          model: "button-one",
          name: "floor",
          position: [0.0, 0.0, 1.0],
          radius: 0.5,
          rotationDegY: 0,
          scale: 0.95,
          tappable: true,
          visible: true,
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
    stepList: [.awaken, .handleInput, .handleEvents],
    worldVector: [1, -1, 1]
  )

  let levelOneCfg: GCFGLevel = GCFGLevel(
    map: GCFGLevel.Map(
      creatures: [
        0, 0,
        0, 0
      ],
      things: [
        1, 0,
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
}
