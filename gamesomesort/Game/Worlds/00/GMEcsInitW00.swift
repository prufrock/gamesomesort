//
//  GMEcsLevelZero.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/23/25.
//
import lecs_swift
import VRTMath
import LECSPieces

struct GMEcsInitW00: GMEcsStarter {
  let config: AppCoreConfig

  func start(ecs: any LECSWorld) {
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
      CTTappable.self,
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

    createPlayerCamera(ecs: ecs)
    createLights(ecs: ecs)
    createFirstGameButton(ecs: ecs)
    createSecondGameButton(ecs: ecs)
    createThirdGameButton(ecs: ecs)
    createBackPlane(ecs: ecs)
  }

  private func createPlayerCamera(ecs: LECSWorld) {
    let playerCamera = ecs.createEntity("playerCamera")
    ecs.addComponent(
      playerCamera,
      LECSPCameraFirstPerson(
        fov: (.pi / 2),
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    ecs.addComponent(playerCamera, LECSPAspect(aspect: 1.0))
    ecs.addComponent(playerCamera, LECSPPosition3d(F3(8, 8, -8.0)))
    // move the origin to the upper left with y=-1.0
    ecs.addComponent(playerCamera, LECSPScale3d(config.game.world.world00.worldBasis))
  }

  private func createFirstGameButton(ecs: LECSWorld) {
    let button = ecs.createEntity(config.game.world.world00.worldOneButtonName)
    ecs.addComponent(button, LECSPPosition3d(8, 2, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(3, 3, 3)))
    ecs.addComponent(button, LECSPColor([0.1, 0.6, 0.0]))
    ecs.addComponent(button, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, LECSPRadius(1.5))
    ecs.addComponent(button, LECSPModel("button-one"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, LECSPTagVisible())
  }

  private func createSecondGameButton(ecs: LECSWorld) {
    let button = ecs.createEntity(config.game.world.world00.worldTwoButtonName)
    ecs.addComponent(button, LECSPPosition3d(8, 5.5, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(3, 3, 3)))
    ecs.addComponent(button, LECSPColor([0.6, 0.1, 0.4]))
    ecs.addComponent(button, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, LECSPRadius(1.5))
    ecs.addComponent(button, LECSPModel("button-one"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, LECSPTagVisible())
  }

  private func createThirdGameButton(ecs: LECSWorld) {
    let button = ecs.createEntity(config.game.world.world00.worldThreeButtonName)
    ecs.addComponent(button, LECSPPosition3d(8, 9, 1.0))
    ecs.addComponent(button, LECSPScale3d(F3(3, 3, 3)))
    ecs.addComponent(button, LECSPColor([0.1, 0.1, 0.4]))
    ecs.addComponent(button, LECSPQuaternion(Float4x4.rotateY(0).q))
    ecs.addComponent(button, LECSPRadius(1.5))
    ecs.addComponent(button, LECSPModel("button-one"))
    ecs.addComponent(button, CTTappable())
    ecs.addComponent(button, LECSPTagVisible())
  }

  private func createBackPlane(ecs: LECSWorld) {
    let backPlane = ecs.createEntity("backPlane")
    ecs.addComponent(backPlane, LECSPPosition3d(10, 10, 3.0))
    ecs.addComponent(backPlane, LECSPScale3d(F3(35, 35, 35)))
    ecs.addComponent(backPlane, LECSPColor([0.0, 0.6, 0.6]))
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
      let position = LECSPPosition3d([6, 3, 1.4])
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
}
