//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import DataStructures
import lecs_swift
import Foundation
import GameConfiguration
import VRTMath
import LECSPieces

typealias GameCommands = DSQueueArray<TBDGWorld.Commands>

public let E_NAME_CAMERA_PLAYER = "playerCamera"
public let E_NAME_TAP_LOCATION = "tapLocation"

public class TBDGWorld {
  public let ecs: LECSWorld
  public var id: LECSId? {
    ecs.entity(worldConfig.name)?.lecsId
  }
  let worldConfig: GCFGWorld
  let levelConfig: GCFGLevel
  // The length of tick in microseconds.
  private var tickDurationUs: UInt64
  private var stepSelector: StepSelector? = nil
  private var screenDimensions = VRTMScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)

  public init(
    worldConfig: GCFGWorld,
    levelConfig: GCFGLevel,
    tickDurationUs: UInt64,
    ecs: LECSWorld
  ) {
    self.ecs = ecs
    self.worldConfig = worldConfig
    self.levelConfig = levelConfig
    self.tickDurationUs = tickDurationUs
  }

  public func restart() {
    let lvlInit = TBDGLevel(world: self, level: "")
    lvlInit.reset()
  }

  public func update(_ dimensions: VRTMScreenDimensions) {
    let activeCamera = ecs.entity(E_NAME_CAMERA_PLAYER)!
    self.screenDimensions = dimensions

    ecs.addComponent(
      activeCamera,
      LECSPAspect(aspect: dimensions.aspectRatio)
    )
  }

  public func update(
    timeStep: Float,
    input: TBDGame.Input
  ) -> any DSQueue<TBDGWorld.Commands> {
    guard let id = id else {
      fatalError("World not initialized in ECS.")
    }

    // Initialize the clock or tick.
    if let clock = ecs.getComponent(id.id, LECSPClock.self) {
      ecs.addComponent(id.id, clock.tick())
    } else {
      ecs.addComponent(id.id, LECSPClock(ticks: 0, tickLengthUs: tickDurationUs))
    }

    let context = StepSelector.Context(
      ecs: ecs,
      config: Config(level: levelConfig, world: worldConfig),
      input: TBDGame.Input(
        events: input.events,
        screenDimensions: screenDimensions
      )
    )

    let selector: StepSelector
    if let existing = stepSelector {
      selector = existing
    } else {
      let created = StepSelector(context: context)
      stepSelector = created
      selector = created
    }

    return selector.run(
      context: context
    )
  }
}

