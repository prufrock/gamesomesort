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
        let button = ecs.createEntity("button\(x),\(y)")
        ecs.addComponent(button, LECSPosition2d(Float2(x.f, y.f)))
      }
    }
  }
}
