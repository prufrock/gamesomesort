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

    for y in 0..<map.height {
      for x in 0..<map.width {
        let tile = map[x, y]
        switch tile {
        case .wall:
          let button = ecs.createEntity("button\(x),\(y)")
          ecs.addComponent(button, LECSPosition2d(Float2(x.f, y.f)))
          ecs.addComponent(button, CTColor(.green))
        case .floor:
          let floor = ecs.createEntity("floor\(x),\(y)")
          ecs.addComponent(floor, LECSPosition2d(Float2(x.f, y.f)))
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
