//
//  LECSExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift
import VRTMath
import LECSPieces

extension LECSWorld {
  func entity(_ name: String) -> LECSEntityId? {
    entity(named: LECSName(name))
  }

  func gmCameraFirstPerson(_ name: String) -> GMCameraFirstPerson? {
    guard
      let playerCamera = entity("playerCamera"),
      let cameraComponent = getComponent(playerCamera, LECSPCameraFirstPerson.self),
      let cameraPosition = getComponent(playerCamera, LECSPPosition3d.self),
      let aspectRatio = getComponent(playerCamera, LECSPAspect.self),
      let cameraScale = getComponent(playerCamera, LECSPScale3d.self)
    else {
      return nil
    }
    return GMCameraFirstPerson(
      transform: GEOTransform(
        position: cameraPosition.position,
        quaternion: Float4x4.identity.q,
        scale: cameraScale.scale
      ),
      aspect: aspectRatio.aspect,
      fov: cameraComponent.fov,
      near: cameraComponent.nearPlane,
      far: cameraComponent.farPlane
    )
  }
}
