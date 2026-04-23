//
//  GMGame.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import Foundation
import SVCFile
import GameConfiguration
//TODO: remove by moving into a TBDGame factory
import TileBasedGame
import lecs_swift

/// Game manages all of the logic of the game. The World is a part of Game because there may be time when Game needs to
/// change World or interrupt it. If World wants to change itself, like change levels, or do something to Game it needs to
/// pass a command up.
class GMGame {
  var world: any GMWorld
  private let levels: [GMTileMap]
  private let appCore: AppCore
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  private var elapsedTime: Float = 0
  private var selectedLevel: Int? = nil

  init(appCore: AppCore, levels: [GMTileMap]) {
    self.appCore = appCore
    self.levels = levels
    world = appCore.createWorldFactory().create(
      level: appCore.config.game.world.initialLevel,
      levels: levels
    )
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move forward.
  func update(timeStep: Float, input: GMGameInput) {

    if selectedLevel == nil {
      initWorld(worldNumber: appCore.config.game.world.initialLevel)
    }

    // reset frequently, just for testing
    if elapsedTime < appCore.config.game.timeLimit {
      var commands = world.update(timeStep: timeStep, input: input)
      elapsedTime += timeStep
      if !commands.isEmpty {
        //TODO: Convert to switch
        let command = commands.dequeue()
        if case let .start(level) = command {
          initWorld(worldNumber: level)
        }
        if case let .startWorld(world) = command {
          //TODO: this a mess, you should feel bad and clean it up!
          let world001Path = levels[0].worlds[world]?.path
          let selectedLevel = "w001L001"

          var worldCfg: GCFGWorld! = nil
          var levelCfg: GCFGLevel! = nil
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(name: world001Path!, ext: .json),
              decodeType: GCFGWorld.self
            ) { (worldData: GCFGWorld) in
              print("worldData \(worldData)")
              worldCfg = worldData

            }
          )
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(
                name: worldCfg.levels[selectedLevel]!.path,
                ext: .json
              ),
              decodeType: GCFGLevel.self
            ) { (levelData: GCFGLevel) in
              print("levelData \(levelData)")
              levelCfg = levelData
            }
          )

          let tbdgWorld = TBDGWorld(
            worldConfig: worldCfg!,
            levelConfig: levelCfg!,
            ecs: LECSCreateWorld(
              archetypeSize: self.appCore.config.game.world.ecsArchetypeSize
            )
          )
          tbdgWorld.reset()
          self.world = tbdgWorld
        }
      }
    } else {
      initWorld(worldNumber: selectedLevel ?? appCore.config.game.world.initialLevel)
      elapsedTime = 0
    }
  }

  private func initWorld(worldNumber: Int) {
    selectedLevel = worldNumber
    world = appCore.createWorldFactory().create(level: worldNumber, levels: levels)
    world.update(screenDimensions)
    appCore.sync(
      SVCCommandRender.ChangeWorld(
        worldBasis: world.basis,
        worldUprightTransforms: world.uprightTransforms
      )
    )
  }

  func update(_ dimensions: ScreenDimensions) {
    self.screenDimensions = dimensions
    world.update(dimensions)
  }
}
