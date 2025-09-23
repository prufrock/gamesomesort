//
//  GMEcsLevelZero.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/23/25.
//
import lecs_swift

struct GMEcsLevelZero: GMEcsStarter {
  func start(ecs: any LECSWorld) {
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

    createPlayerCamera(ecs: ecs)
    createLights(ecs: ecs)
    createBackPlane(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      CTCameraFirstPerson(
        // negate fov to flip the y-axis, without messing with the winding order
        fov: -1 * (.pi / 2),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, CTAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, CTPosition3d(F3(8, 8, -8.0)))
    ecs.addComponent(playerCamera, CTScale3d(F3(1.0, 1.0, 1.0)))
  }

  private func createBackPlane(ecs: LECSWorld) {
    let backPlane = ecs.createEntity("backPlane")
    ecs.addComponent(backPlane, CTPosition3d(10, 10, 1.5))
    ecs.addComponent(backPlane, CTScale3d(uniform: 35))
    ecs.addComponent(backPlane, CTColor([0.0, 0.6, 0.6]))
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
      light.attenuation = [0.2, 10, 50]
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
}
