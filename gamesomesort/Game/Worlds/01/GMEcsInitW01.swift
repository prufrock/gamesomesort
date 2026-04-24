//
//  GMEcsInitializer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/16/25.
//

import lecs_swift
import VRTMath
import LECSPieces

protocol GMEcsStarter {
  func start(ecs: LECSWorld)
}

struct GMEcsInitW01: GMEcsStarter {
  let map: GMTileMap
  let config: AppCoreConfig
  let worldVector: F3

  init(map: GMTileMap, config: AppCoreConfig) {
    self.map = map
    self.config = config
    self.worldVector = config.game.world.world01.worldBasis
  }

  func start(ecs: LECSWorld) {

    let componentTypes: [LECSComponent.Type] = [
      LECSPAspect.self,
      CTBalloonEmitter.self,
      LECSPCameraFirstPerson.self,
      LECSPColor.self,
      LECSPLight.self,
      LECSPModel.self,
      CTTagBalloon.self,
      CTTagTap.self,
      LECSPTagVisible.self,
      LECSPQuaternion.self,
      LECSPRadius.self,
      LECSPScale3d.self,
      LECSPosition2d.self,
      LECSVelocity2d.self,
    ]

    // use all of the components once, so they exist in the system
    let placeHolderName = "placeHolder"
    let placeHolderId = ecs.createEntity(placeHolderName)

    componentTypes.forEach {
      ecs.addComponent(placeHolderId, $0.init())
      ecs.removeComponent(placeHolderId, component: $0)
    }

    map.locations { tile, thing, xy in
      let x = xy.0
      let y = xy.1

      createTile(ecs: ecs, tile: tile, x: x, y: y)
      createThing(ecs: ecs, thing: thing, x: x, y: y)
    }

    createPlayerCamera(ecs: ecs)

    let firstEmitter = ecs.createEntity("firstEmitter")
    ecs.addComponent(firstEmitter, LECSPPosition3d(x: 5, y: 20, z: 1))
    ecs.addComponent(
      firstEmitter,
      CTBalloonEmitter(
        rate: 20.1,
        timer: 0.0
      )
    )

    let secondEmitter = ecs.createEntity("secondEmitter")
    ecs.addComponent(secondEmitter, LECSPPosition3d(x: 8, y: 20, z: 1))
    ecs.addComponent(
      secondEmitter,
      CTBalloonEmitter(
        rate: 10.3,
        timer: 0.0
      )
    )

    let thirdEmitter = ecs.createEntity("thirdEmitter")
    ecs.addComponent(thirdEmitter, LECSPPosition3d(x: 12, y: 20, z: 1))
    ecs.addComponent(
      thirdEmitter,
      CTBalloonEmitter(
        rate: 18.7,
        timer: 0.0
      )
    )

    createLights(ecs: ecs)
    createBackPlane(ecs: ecs)
    createExitButton(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      LECSPCameraFirstPerson(
        // negate fov to flip the y-axis, without messing with the winding order
        fov: -1 * (.pi / 2),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, LECSPAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, LECSPPosition3d(F3(8, 8, -8.0)))
    ecs.addComponent(playerCamera, LECSPScale3d(worldVector))
  }

  private func createTile(ecs: LECSWorld, tile: GMTile, x: Int, y: Int) {
    switch tile {
    case .wall:
      let wall = ecs.createEntity("wall\(x),\(y)")
      ecs.addComponent(wall, LECSPosition2d(Float2(x.f, y.f)))
      ecs.addComponent(wall, LECSPRadius(0.5))
      ecs.addComponent(wall, LECSPColor(.green))
    case .floor:
      let floor = ecs.createEntity("floor\(x),\(y)")
      ecs.addComponent(floor, LECSPosition2d(Float2(x.f, y.f)))
    }
  }

  private func createThing(ecs: LECSWorld, thing: GMThing, x: Int, y: Int) {
    switch thing {
    case .balloon:
      let balloon = ecs.createEntity("balloon\(x),\(y)")
      ecs.addComponent(balloon, LECSPosition2d(Float2(x.f, y.f)))
      ecs.addComponent(balloon, LECSPRadius(1.0))
      ecs.addComponent(balloon, LECSPColor(.yellow))
      ecs.addComponent(balloon, LECSPTagVisible())
      ecs.addComponent(balloon, CTTagBalloon())
      ecs.addComponent(balloon, LECSVelocity2d(x: 0.0, y: -0.005))
    case .nothing:
      //no-op
      break
    default:
      print("Oh dang, unknown thing at (\(x),\(y))")
    }
  }

  private func createBackPlane(ecs: LECSWorld) {
    let backPlane = ecs.createEntity("backPlane")
    ecs.addComponent(backPlane, LECSPPosition3d(10, 10, 2.5))
    ecs.addComponent(backPlane, LECSPScale3d(F3(repeating: 35)))
    ecs.addComponent(backPlane, LECSPColor([0.6, 0.6, 0.6]))
    ecs.addComponent(backPlane, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(backPlane, LECSPModel("back-plane"))
    ecs.addComponent(backPlane, LECSPTagVisible())
  }

  private func createLights(ecs: LECSWorld) {
    _ = {
      var sun = LECSPLight()
      sun.type = .Sun
      let color = LECSPColor([1, 1, 1])
      let position = LECSPPosition3d([0, 0, -1])
      let id = ecs.createEntity("sun")
      ecs.addComponent(id, sun)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = LECSPLight()
      light.type = .Spot
      light.coneDirection = [1, 1, 0]
      let color = LECSPColor([1, 0.5, 0.5])
      let position = LECSPPosition3d([10, 7, 0.2])
      let id = ecs.createEntity("spotLight")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = LECSPLight()
      light.type = .Point
      light.attenuation = [0.2, 10, 50]
      light.specularColor = F3(repeating: 0.6)
      let color = LECSPColor([0, 0.5, 0.5])
      let position = LECSPPosition3d([6, 3, 2.4])
      let id = ecs.createEntity("pointLight")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = LECSPLight()
      light.type = .Point
      light.attenuation = [0.8, 20, 50]
      light.specularColor = F3(repeating: 0.6)
      let color = LECSPColor([0.5, 0, 0.5])
      let position = LECSPPosition3d([8, 14, 0.0])
      let id = ecs.createEntity("pointLightTwo")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()
  }

  private func createExitButton(ecs: LECSWorld) {
    let button = ecs.createEntity(config.game.world.world02.exitButton)
    ecs.addComponent(button, LECSPPosition3d(10, 1, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(repeating: 1)))
    ecs.addComponent(button, LECSPColor([1.0, 1.0, 1.0]))
    ecs.addComponent(button, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, LECSPRadius(1.5))
    ecs.addComponent(button, LECSPModel("back-plane"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, LECSPTagVisible())
  }
}
