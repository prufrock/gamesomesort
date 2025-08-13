//
//  GMEcsInitializer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/16/25.
//

import lecs_swift

protocol GMEcsStarter {
  func start(ecs: LECSWorld)
}

struct GMStartFromTileMap: GMEcsStarter {
  let map: GMTileMap

  func start(ecs: LECSWorld) {

    let componentTypes: [LECSComponent.Type] = [
      CTAspect.self,
      CTBalloonEmitter.self,
      CTCameraFirstPerson.self,
      CTColor.self,
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

    let firstEmitter = ecs.createEntity("firstEmitter")
    ecs.addComponent(firstEmitter, LECSPosition2d(x: 5, y: 20))
    ecs.addComponent(
      firstEmitter,
      CTBalloonEmitter(
        rate: 20.1,
        timer: 0.0
      )
    )

    let secondEmitter = ecs.createEntity("secondEmitter")
    ecs.addComponent(secondEmitter, LECSPosition2d(x: 8, y: 20))
    ecs.addComponent(
      secondEmitter,
      CTBalloonEmitter(
        rate: 10.3,
        timer: 0.0
      )
    )

    let thirdEmitter = ecs.createEntity("thirdEmitter")
    ecs.addComponent(thirdEmitter, LECSPosition2d(x: 12, y: 20))
    ecs.addComponent(
      thirdEmitter,
      CTBalloonEmitter(
        rate: 18.7,
        timer: 0.0
      )
    )

    createLights(ecs: ecs)
    createBackPlane(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      CTCameraFirstPerson(
        fov: .pi / 2,
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, CTAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, CTPosition3d(F3(8, 8, -8.0)))
    ecs.addComponent(playerCamera, CTScale3d(F3(1.0, -1.0, 1.0)))
  }

  private func createTile(ecs: LECSWorld, tile: GMTile, x: Int, y: Int) {
    switch tile {
    case .wall:
      let wall = ecs.createEntity("wall\(x),\(y)")
      ecs.addComponent(wall, LECSPosition2d(Float2(x.f, y.f)))
      ecs.addComponent(wall, CTRadius(0.5))
      ecs.addComponent(wall, CTColor(.green))
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
      ecs.addComponent(balloon, CTRadius(1.0))
      ecs.addComponent(balloon, CTColor(.yellow))
      ecs.addComponent(balloon, CTTagVisible())
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
    ecs.addComponent(backPlane, CTPosition3d(10, 10, 1.5))
    ecs.addComponent(backPlane, CTScale3d(uniform: 35))
    ecs.addComponent(backPlane, CTColor([0.6, 0.6, 0.6]))
    ecs.addComponent(backPlane, CTQuaternion(simd_quatf(Float4x4.rotateY(-.pi / 2))))
    ecs.addComponent(backPlane, CTModel("back-plane"))
    ecs.addComponent(backPlane, CTTagVisible())
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
      light.attenuation = [1, 0, 0]
      light.specularColor = F3(repeating: 0.6)
      let color = CTColor([0, 0.5, 0.5])
      let position = CTPosition3d([6, 3, 1.4])
      let id = ecs.createEntity("pointLight")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()

    _ = {
      var light = CTLight()
      light.type = Point
      light.attenuation = [1, 0, 0]
      light.specularColor = F3(repeating: 0.6)
      let color = CTColor([0.5, 0, 0.5])
      let position = CTPosition3d([12, 8, 1.4])
      let id = ecs.createEntity("pointLightTwo")
      ecs.addComponent(id, light)
      ecs.addComponent(id, color)
      ecs.addComponent(id, position)
    }()
  }
}
