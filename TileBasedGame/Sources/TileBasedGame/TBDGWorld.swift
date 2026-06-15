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
  let worldConfig: GCFGWorld
  let levelConfig: GCFGLevel
  private var screenDimensions = VRTMScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)

  public init(
    worldConfig: GCFGWorld,
    levelConfig: GCFGLevel,
    ecs: LECSWorld
  ) {
    self.ecs = ecs
    self.worldConfig = worldConfig
    self.levelConfig = levelConfig
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

    return StepSelector().run(
      context: StepSelector.Context(
        ecs: ecs,
        config: Config(level: levelConfig, world: worldConfig),
        input: TBDGame.Input(
          events: input.events,
          screenDimensions: screenDimensions
        )
      )
    )
  }
}

