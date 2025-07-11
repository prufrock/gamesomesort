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
      CTCameraFirstPerson.self,
      CTColor.self,
      CTTagTap.self,
      CTRadius.self,
      CTScale3d.self,
      LECSPosition2d.self,
    ]

    // use all of the components once, so they exist in the system
    let placeHolderName = "placeHolder"
    let placeHolderId = ecs.createEntity(placeHolderName)

    componentTypes.forEach {
      ecs.addComponent(placeHolderId, $0.init())
      ecs.removeComponent(placeHolderId, component: $0)
    }

    for y in 0..<map.height {
      for x in 0..<map.width {
        let tile = map[x, y]
        switch tile {
        case .wall:
          let wall = ecs.createEntity("wall\(x),\(y)")
          ecs.addComponent(wall, LECSPosition2d(Float2(x.f, y.f)))
          ecs.addComponent(wall, CTRadius(0.5))
          ecs.addComponent(wall, CTColor(.green))
        case .floor:
          let floor = ecs.createEntity("floor\(x),\(y)")
          ecs.addComponent(floor, LECSPosition2d(Float2(x.f, y.f)))
          ecs.addComponent(floor, CTRadius(0.5))
          ecs.addComponent(floor, CTColor(.blue))
        }
      }
    }

    createPlayerCamera(ecs: ecs)
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
    ecs.addComponent(playerCamera, CTPosition3d(F3(8, 8, -10.0)))
    ecs.addComponent(playerCamera, CTScale3d(F3(1.0, -1.0, 1.0)))
  }
}
