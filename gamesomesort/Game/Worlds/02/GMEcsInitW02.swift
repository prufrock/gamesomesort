//
//  GMEcsLevelZero.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/23/25.
//
import lecs_swift

struct GMEcsInitW02: GMEcsStarter {
  let map: GMTileMap
  let config: AppCoreConfig
  private let worldVector: F3

  init(map: GMTileMap, config: AppCoreConfig) {
    self.map = map
    self.config = config
    self.worldVector = config.game.world.world02.worldBasis
  }

  func start(ecs: LECSWorld) {

    let componentTypes: [LECSComponent.Type] = [
      CTAspect.self,
      CTBalloonEmitter.self,
      CTCameraFirstPerson.self,
      CTColor.self,
      CTEvent.self,
      CTLight.self,
      CTModel.self,
      CTTagBalloon.self,
      CTTagTap.self,
      CTTagVisible.self,
      CTQuaternion.self,
      CTRadius.self,
      CTScale3d.self,
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

    createLights(ecs: ecs)
    createBackPlane(ecs: ecs)
    createExitButton(ecs: ecs)
    createButtons(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      CTCameraFirstPerson(
        fov: 1 * (.pi / 2),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, CTAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, CTPosition3d(F3(3.5, 4, -7.25)))
    ecs.addComponent(playerCamera, CTScale3d(worldVector))
  }

  private func createTile(ecs: LECSWorld, tile: GMTile, x: Int, y: Int) {
    switch tile {
    case .wall:
      let wall = ecs.createEntity("tile\(x),\(y)")
      ecs.addComponent(wall, CTPosition3d(x.f, y.f, 1.0))
      ecs.addComponent(wall, CTRadius(0.5))
      ecs.addComponent(wall, CTColor(.green))
      ecs.addComponent(wall, CTScale3d(F3(x: 1, y: 1, z: 1)))
      ecs.addComponent(wall, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
      ecs.addComponent(wall, CTModel("back-plane"))
      ecs.addComponent(wall, CTTagVisible())
      ecs.addComponent(wall, CTTile(.wall))
      ecs.addComponent(wall, CTTappable())
    case .floor:
      let floor = ecs.createEntity("tile\(x),\(y)")
      ecs.addComponent(floor, CTPosition3d(x.f, y.f, 1.8))
      ecs.addComponent(floor, CTRadius(0.5))
      ecs.addComponent(floor, CTColor(.yellow))
      ecs.addComponent(floor, CTScale3d(F3(x: 0.9, y: 0.9, z: 0.9)))
      ecs.addComponent(floor, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
      ecs.addComponent(floor, CTModel("back-plane"))
      ecs.addComponent(floor, CTTagVisible())
      ecs.addComponent(floor, CTTile(.floor))
      ecs.addComponent(floor, CTTappable())
    }
  }

  private func createThing(ecs: LECSWorld, thing: GMThing, x: Int, y: Int) {
    switch thing {
    case .balloon:
      let balloon = ecs.createEntity("balloon\(x),\(y)")
      ecs.addComponent(balloon, LECSPosition2d(Float2(x.f, y.f)))
      ecs.addComponent(balloon, CTRadius(1.0))
      ecs.addComponent(balloon, CTColor(.yellow))
      ecs.addComponent(balloon, CTTagVisible())
      ecs.addComponent(balloon, CTTagBalloon())
      ecs.addComponent(balloon, LECSVelocity2d(x: 0.0, y: -0.005))
      ecs.addComponent(balloon, CTScale3d(F3(repeating: 1)))
    case .player:
      createPlayer(ecs: ecs, position: F2(x.f, y.f))
      let start = ecs.createEntity("start")
      ecs.addComponent(start, CTPosition3d(x.f, y.f, 1.79))
      ecs.addComponent(start, CTScale3d(F3(x: 0.5, y: 0.5, z: 0.5)))
      ecs.addComponent(start, CTColor(color: GMColorA(.orange)))
      ecs.addComponent(start, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
      ecs.addComponent(start, CTModel("back-plane"))
      ecs.addComponent(start, CTTagVisible())
    case .end:
      let end = ecs.createEntity("end\(x),\(y)")
      ecs.addComponent(end, CTPosition3d(x.f, y.f, 1.79))
      ecs.addComponent(end, CTScale3d(F3(x: 0.5, y: 0.5, z: 0.5)))
      ecs.addComponent(end, CTColor([0.6, 0.0, 0.0]))
      ecs.addComponent(end, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
      ecs.addComponent(end, CTModel("back-plane"))
      ecs.addComponent(end, CTTagVisible())
      ecs.addComponent(end, CTThing(.end))
    case .nothing:
      //no-op
      break
    default:
      print("Oh dang, unknown thing at (\(x),\(y))")
    }
  }

  private func createBackPlane(ecs: LECSWorld) {
    let backPlane = ecs.createEntity("backPlane")
    ecs.addComponent(backPlane, CTPosition3d(10, 10, 2.5))
    ecs.addComponent(backPlane, CTScale3d(F3(x: 35, y: 35, z: 35)))
    ecs.addComponent(backPlane, CTColor([0.6, 0.6, 0.6]))
    ecs.addComponent(backPlane, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
    ecs.addComponent(backPlane, CTModel("back-plane"))
    ecs.addComponent(backPlane, CTTagVisible())
  }

  private func createPlayer(ecs: LECSWorld, position: Float2) {
    let player = ecs.createEntity("player01")
    ecs.addComponent(player, CTPosition3d(x: position.x, y: position.y, z: 1.0))
    ecs.addComponent(player, CTColor(.black))
    ecs.addComponent(player, CTRadius(1.0))
    ecs.addComponent(player, CTTagVisible())
    ecs.addComponent(player, CTModel("brick-sphere.usdz"))
    ecs.addComponent(player, CTQuaternion(simd_quatf(Float4x4.identity)))
    ecs.addComponent(player, CTScale3d(F3(repeating: 0.5)))
  }

  private func createLights(ecs: LECSWorld) {
    _ = {
      var sun = CTLight()
      sun.type = Sun
      let color = CTColor([1, 1, 1])
      let position = CTPosition3d([0, 0, -1])
      let id = ecs.createEntity("sun")
      ecs.addComponent(id, sun)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = CTLight()
      light.type = Spot
      light.coneDirection = [1, 1, 0]
      let color = CTColor([1, 0.5, 0.5])
      let position = CTPosition3d([10, 7, 0.2])
      let id = ecs.createEntity("spotLight")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = CTLight()
      light.type = Point
      light.attenuation = [0.2, 10, 50]
      light.specularColor = F3(repeating: 0.6)
      let color = CTColor([0, 0.5, 0.5])
      let position = CTPosition3d([6, 3, 2.4])
      let id = ecs.createEntity("pointLight")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = CTLight()
      light.type = Point
      light.attenuation = [0.2, 10, 50]
      light.specularColor = F3(repeating: 0.6)
      let color = CTColor([0, 0.5, 0.5])
      let position = CTPosition3d([5, 3, 2.4])
      let id = ecs.createEntity("pointLightagain")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = CTLight()
      light.type = Point
      light.attenuation = [0.8, 20, 50]
      light.specularColor = F3(repeating: 0.6)
      let color = CTColor([0.5, 0, 0.5])
      let position = CTPosition3d([8, 14, 0.0])
      let id = ecs.createEntity("pointLightTwo")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()
  }

  private func createButtons(ecs: LECSWorld) {
    for button in config.game.world.world02.buttons {
      let entity = ecs.createEntity(button.name)
      ecs.addComponent(entity, CTPosition3d(button.position))
      ecs.addComponent(entity, CTScale3d(button.scale))
      ecs.addComponent(entity, CTColor(button.color))
      ecs.addComponent(entity, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
      ecs.addComponent(entity, CTRadius(button.radius))
      ecs.addComponent(entity, CTModel(button.model))
      ecs.addComponent(entity, CTTappable())
      ecs.addComponent(entity, CTTagVisible())

      if button.locking {
        ecs.addComponent(entity, CTLockingButton())
      }
    }
  }

  private func createExitButton(ecs: LECSWorld) {
    let button = ecs.createEntity(config.game.world.world02.exitButton)
    ecs.addComponent(button, CTPosition3d(1.0, -2, 1.0))
    ecs.addComponent(button, CTScale3d(F3(repeating: 1)))
    ecs.addComponent(button, CTColor([1.0, 1.0, 1.0]))
    ecs.addComponent(button, CTQuaternion(simd_quatf(Float4x4.rotateY(0))))
    ecs.addComponent(button, CTRadius(0.5))
    ecs.addComponent(button, CTModel("back-plane"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, CTTagVisible())
  }
}
