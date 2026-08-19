//
//  LECSWorldExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/18/26.
//

import lecs_swift
import LECSPieces

extension LECSWorld {
  func gameObjects(context: RNDRContext) -> [RNDRGameObject] {
    var gameObjects = [RNDRGameObject]()
    select(
      [
        LECSPModel.self,
        LECSPPosition3d.self,
        LECSPScale3d.self,
        LECSPQuaternion.self,
        LECSPColor.self,
        LECSPTag.Visible.self,
      ]
    ) { row, columns in
      let LECSPModel = row.component(at: 0, columns, LECSPModel.self)
      let position = row.component(at: 1, columns, LECSPPosition3d.self)
      let scale = row.component(at: 2, columns, LECSPScale3d.self)
      let quaternion = row.component(at: 3, columns, LECSPQuaternion.self)
      let color = row.component(at: 4, columns, LECSPColor.self)

      let gameObject = RNDRGameObject(
        name: LECSPModel.name,
        transform: GEOTransform(
          position: position.position,
          quaternion: quaternion.quaternion,
          scale: scale.scale
        ),
        model: context.controllerModel.models[LECSPModel.name]!,
        baseColor: color.f3
      )

      gameObjects.append(gameObject)
    }
    return gameObjects
  }
}

extension LECSWorld {
  var lights: [SHDRLight] {
    var lights: [SHDRLight] = []
    select([LECSPPosition3d.self, LECSPLight.self, LECSPColor.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPPosition3d.self)
      let light = row.component(at: 1, columns, LECSPLight.self)
      let color = row.component(at: 2, columns, LECSPColor.self)

      var shdrLight = SHDRLight()

      shdrLight.position = position.position
      shdrLight.radius = 0
      shdrLight.color = color.f3
      shdrLight.type = light.type.lightType
      shdrLight.coneDirection = light.coneDirection
      shdrLight.attenuation = light.attenuation
      shdrLight.coneAngle = light.coneAngle
      shdrLight.coneAttenutation = light.coneAttenuation
      shdrLight.coneDirection = light.coneDirection

      lights.append(shdrLight)
    }

    return lights
  }
}
