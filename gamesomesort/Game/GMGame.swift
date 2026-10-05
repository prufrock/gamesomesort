//
//  GMGame.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import Foundation
import GameConfiguration
import SVCFile
//TODO: remove by moving into a TBDGame factory
import TileBasedGame
import RenderObjects
import VRTMath
import lecs_swift
import LECSPieces

/// Game manages all of the logic of the game. The World is a part of Game because there may be time when Game needs to
/// change World or interrupt it. If World wants to change itself, like change levels, or do something to Game it needs to
/// pass a command up.
class GMGame {
  var world: any GMWorld
  private let levels: [GMTileMap]
  private let appCore: AppCore
  private var screenDimensions = VRTMScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  private var elapsedTime: Float = 0
  private var selectedLevel: Int? = nil
  public var scene: ROScene {

    let ecs = world.ecs

    let camera = {
      let playerCamera = ecs.entity("playerCamera")!
      let cameraComponent = ecs.getComponent(playerCamera, LECSPCameraFirstPerson.self)!
      let cameraPosition = ecs.getComponent(playerCamera, LECSPPosition3d.self)!
      let aspectRatio = ecs.getComponent(playerCamera, LECSPAspect.self)!
      let cameraScale = ecs.getComponent(playerCamera, LECSPScale3d.self)!

      return ROCameraFirstPerson(
        transform: ROTransform(
          position: cameraPosition.position,
          quaternion: Float4x4.identity.q,
          scale: cameraScale.scale
        ),
        aspect: aspectRatio.aspect,
        fov: cameraComponent.fov,
        near: cameraComponent.nearPlane,
        far: cameraComponent.farPlane
      )
    }()

    let sun: ROPosition = {
      let sun = ecs.entity("sun")!
      let position = ecs.getComponent(sun, LECSPPosition3d.self)!

      return ROPosition(
        position: position.position
      )
    }()

    let lights: [ROLight] = {
      var lights: [ROLight] = []
      ecs.select([LECSPPosition3d.self, LECSPLight.self, LECSPColor.self]) { row, columns in
        let position = row.component(at: 0, columns, LECSPPosition3d.self)
        let light = row.component(at: 1, columns, LECSPLight.self)
        let color = row.component(at: 2, columns, LECSPColor.self)

        let roLight = ROLight(
          attenuation: light.attenuation,
          color: color.f3,
          coneAngle: light.coneAngle,
          coneAttenuation: light.coneAttenuation,
          coneDirection: light.coneDirection,
          position: position.position,
          radius: 0,
          specularColor: light.specularColor,
          type: ROLight.LightType(rawValue: light.type.rawValue) ?? ROLight.LightType.unused
        )

        lights.append(roLight)
      }

      return lights
    }()

    let gameObjects: [ROGameObject] = {
      var collectedObjects: [ROGameObject] = []
      ecs.select(
        [
          LECSPModel.self,
          LECSPPosition3d.self,
          LECSPScale3d.self,
          LECSPQuaternion.self,
          LECSPColor.self,
          LECSPTag.Visible.self,
        ]
      ) { row, columns in
        let model = row.component(at: 0, columns, LECSPModel.self)
        let position = row.component(at: 1, columns, LECSPPosition3d.self)
        let scale = row.component(at: 2, columns, LECSPScale3d.self)
        let quaternion = row.component(at: 3, columns, LECSPQuaternion.self)
        let color = row.component(at: 4, columns, LECSPColor.self)

        let gameObject = ROGameObject(
          color: color.f3,
          model: model.name,
          name: model.name,
          transform: ROTransform(
            position: position.position,
            quaternion: quaternion.quaternion,
            scale: scale.scale
          ),
        )

        collectedObjects.append(gameObject)
      }
      return collectedObjects
    }()

    return ROSceneFlat(
      cameraPlayerOne: camera,
      gameObjects: gameObjects,
      lights: lights,
      sun: sun,
      upVector: appCore.config.game.upVector
    )
  }

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
  func update(timeStep: Float, input: TBDGame.Input) {

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
        if case let .startWorld(world, level) = command {
          //TODO: this a mess, you should feel bad and clean it up!
          let world001Path = levels[0].worlds[world]?.path
          let selectedLevel = level

          var worldCfg: GCFGWorld! = nil
          var levelCfg: GCFGLevel! = nil
          #if os(macOS) && DEBUG
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(name: world001Path!, ext: .json),
              decodeType: GCFGWorld.self,
              filePath: URL(
                fileURLWithPath: "~/Music/gamesomesort/Worlds/World001"
              )
            ) { (worldData: GCFGWorld) in
              worldCfg = worldData

            }
          )
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(
                name: worldCfg.levels[selectedLevel]!.path,
                ext: .json
              ),
              decodeType: GCFGLevel.self,
              filePath: URL(
                fileURLWithPath: "~/Music/gamesomesort/Worlds/World001"
              )
            ) { (levelData: GCFGLevel) in
              levelCfg = levelData
            }
          )
          #else
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(name: world001Path!, ext: .json),
              decodeType: GCFGWorld.self,
              bundle: .main
            ) { (worldData: GCFGWorld) in
              worldCfg = worldData

            }
          )
          appCore.sync(
            LoadJsonFileCommand(
              fileDescriptor: SVCFileDescriptor(
                name: worldCfg.levels[selectedLevel]!.path,
                ext: .json
              ),
              decodeType: GCFGLevel.self,
              bundle: .main
            ) { (levelData: GCFGLevel) in
              levelCfg = levelData
            }
          )
          #endif  // os(macOS) && DEBUG

          let tbdgWorld = TBDGWorld(
            worldConfig: worldCfg!,
            levelConfig: levelCfg!,
            ecs: LECSCreateWorld(
              archetypeSize: self.appCore.config.game.world.ecsArchetypeSize
            )
          )
          tbdgWorld.restart()
          tbdgWorld.update(screenDimensions)
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

  func update(_ dimensions: VRTMScreenDimensions) {
    self.screenDimensions = dimensions
    world.update(dimensions)
  }
}
