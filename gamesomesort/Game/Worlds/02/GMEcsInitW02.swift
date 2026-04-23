//
//  GMEcsLevelZero.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/23/25.
//
import lecs_swift
import VRTMath
import LECSPieces

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
      LECSPAspect.self,
      CTBalloonEmitter.self,
      LECSPCameraFirstPerson.self,
      CTColor.self,
      CTEvent.self,
      CTLight.self,
      CTModel.self,
      CTTagBalloon.self,
      CTTagTap.self,
      CTTagVisible.self,
      CTQuaternion.self,
      CTRadius.self,
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

    createLights(ecs: ecs)
    createBackPlane(ecs: ecs)
    createExitButton(ecs: ecs)
    createButtons(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      LECSPCameraFirstPerson(
        fov: 1 * (.pi / 2),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, LECSPAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, LECSPPosition3d(F3(3.5, 4, -7.25)))
    ecs.addComponent(playerCamera, LECSPScale3d(worldVector))
  }

  private func createTile(ecs: LECSWorld, tile: GMTile, x: Int, y: Int) {
    switch tile {
    case .wall:
      let wall = ecs.createEntity("tile\(x),\(y)")
      ecs.addComponent(wall, LECSPPosition3d(x.f, y.f, 1.0))
      ecs.addComponent(wall, CTRadius(0.5))
      ecs.addComponent(wall, CTColor(.green))
      ecs.addComponent(wall, LECSPScale3d(F3(x: 1, y: 1, z: 1)))
      ecs.addComponent(wall, CTQuaternion(Float4x4.rotateY(0).q))
      ecs.addComponent(wall, CTModel("back-plane"))
      ecs.addComponent(wall, CTTagVisible())
      ecs.addComponent(wall, CTTile(.wall))
      ecs.addComponent(wall, CTTappable())
    case .floor:
      let floor = ecs.createEntity("tile\(x),\(y)")
      ecs.addComponent(floor, LECSPPosition3d(x.f, y.f, 1.8))
      ecs.addComponent(floor, CTRadius(0.5))
      ecs.addComponent(floor, CTColor(.yellow))
      ecs.addComponent(floor, LECSPScale3d(F3(x: 0.9, y: 0.9, z: 0.9)))
      ecs.addComponent(floor, CTQuaternion(Float4x4.rotateY(0).q))
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
      ecs.addComponent(balloon, LECSPScale3d(F3(repeating: 1)))
    case .player:
      createPlayer(ecs: ecs, position: F2(x.f, y.f))
      let start = ecs.createEntity("start")
      ecs.addComponent(start, LECSPPosition3d(x.f, y.f, 1.79))
      ecs.addComponent(start, LECSPScale3d(F3(x: 0.5, y: 0.5, z: 0.5)))
      ecs.addComponent(start, CTColor(color: GMColorA(.orange)))
      ecs.addComponent(start, CTQuaternion(Float4x4.rotateY(0).q))
      ecs.addComponent(start, CTModel("back-plane"))
      ecs.addComponent(start, CTTagVisible())
    case .end:
      let end = ecs.createEntity("end\(x),\(y)")
      ecs.addComponent(end, LECSPPosition3d(x.f, y.f, 1.79))
      ecs.addComponent(end, LECSPScale3d(F3(x: 0.5, y: 0.5, z: 0.5)))
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
    ecs.addComponent(backPlane, LECSPPosition3d(10, 10, 2.5))
    ecs.addComponent(backPlane, LECSPScale3d(F3(x: 35, y: 35, z: 35)))
    ecs.addComponent(backPlane, CTColor([0.6, 0.6, 0.6]))
    ecs.addComponent(backPlane, CTQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(backPlane, CTModel("back-plane"))
    ecs.addComponent(backPlane, CTTagVisible())
  }

  private func createPlayer(ecs: LECSWorld, position: Float2) {
    let player = ecs.createEntity("player01")
    ecs.addComponent(player, LECSPPosition3d(x: position.x, y: position.y, z: 1.0))
    ecs.addComponent(player, CTColor(.black))
    ecs.addComponent(player, CTRadius(1.0))
    ecs.addComponent(player, CTTagVisible())
    ecs.addComponent(player, CTModel("square-bella.usdz"))
    ecs.addComponent(player, CTQuaternion(Float4x4.rotateY(.pi).q))
    ecs.addComponent(player, LECSPScale3d(F3(repeating: 0.5)))
  }

  private func createLights(ecs: LECSWorld) {
    _ = {
      var sun = CTLight()
      sun.type = Sun
      let color = CTColor([1, 1, 1])
      let position = LECSPPosition3d([0, 0, -1])
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
      let position = LECSPPosition3d([10, 7, 0.2])
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
      let position = LECSPPosition3d([6, 3, 2.4])
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
      let position = LECSPPosition3d([5, 3, 2.4])
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
      let position = LECSPPosition3d([8, 14, 0.0])
      let id = ecs.createEntity("pointLightTwo")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()
  }

  private func createButtons(ecs: LECSWorld) {
    for button in config.game.world.world02.buttons {
      let entity = ecs.createEntity(button.name)
      ecs.addComponent(entity, LECSPPosition3d(button.position))
      ecs.addComponent(entity, LECSPScale3d(button.scale))
      ecs.addComponent(entity, CTColor(button.color))
      ecs.addComponent(entity, CTQuaternion(Float4x4.rotateY(0).q))
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
    ecs.addComponent(button, LECSPPosition3d(1.0, -2, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(repeating: 0.5)))
    ecs.addComponent(button, CTColor([1.0, 1.0, 1.0]))
    ecs.addComponent(button, CTQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, CTRadius(0.5))
    ecs.addComponent(button, CTModel("brick-sphere.usdz"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, CTTagVisible())
  }
}
