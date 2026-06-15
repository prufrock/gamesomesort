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

  var countPlayers = 0
  world.ecs.select([LECSPPlayer.self]) { rows, columns in
    countPlayers += 1
  }
  #expect(countPlayers == 1)
}

private func startWorld() -> TBDGWorld {
  let helper = TestHelpers()

  let ecs = LECSCreateWorld(archetypeSize: 100)

  let world = TBDGWorld(
    worldConfig: helper.worldCfg,
    levelConfig: helper.levelOneCfg,
    ecs: ecs
  )

  world.restart()

  return world
}
