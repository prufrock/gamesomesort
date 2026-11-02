//
//  LECSWorldExts.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/4/26.
//

import lecs_swift
import VRTMath
import LECSPieces

extension LECSWorld {
  func vrtmCameraPerspective(_ name: String) -> VRTMCameraPerspective? {
    guard
      let playerCamera = entity("playerCamera"),
      let cameraComponent = getComponent(playerCamera, LECSPCameraFirstPerson.self),
      let cameraPosition = getComponent(playerCamera, LECSPPosition3d.self),
      let aspectRatio = getComponent(playerCamera, LECSPAspect.self),
      let cameraScale = getComponent(playerCamera, LECSPScale3d.self)
    else {
      return nil
    }
    return VRTMCameraPerspective(
      aspect: aspectRatio.aspect,
      far: cameraComponent.farPlane,
      fov: cameraComponent.fov,
      near: cameraComponent.nearPlane,
      transform: VRTMTransform(
        position: cameraPosition.position,
        quaternion: Float4x4.identity.q,
        scale: cameraScale.scale
      )
    )
  }

  func findEntity(at position: F3, type: LECSPEntityType) -> LECSId? {
    var entityId: LECSId? = nil
    select([LECSId.self, LECSPPosition3d.self, LECSPEntity.self]) { row, columns in
      let foundId = row.component(at: 0, columns, LECSId.self)
      let foundPosition = row.component(at: 1, columns, LECSPPosition3d.self)
      let foundEntity = row.component(at: 2, columns, LECSPEntity.self)

      if foundPosition.x >= position.x && foundPosition.x <= position.x.rounded(.up)
          && foundPosition.y >= position.y && foundPosition.y <= position.y.rounded(.up)
          && foundEntity.type == type {
        entityId = foundId
      }
    }
    return entityId
  }
}
