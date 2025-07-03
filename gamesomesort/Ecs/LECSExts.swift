//
//  LECSExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift

extension LECSWorld {
  func entity(_ name: String) -> LECSEntityId? {
    entity(named: LECSName(name))
  }

  func gmCameraFirstPerson(_ name: String) -> GMCameraFirstPerson? {
    guard
      let playerCamera = entity("playerCamera"),
      let cameraComponent = getComponent(playerCamera, CTCameraFirstPerson.self),
      let cameraPosition = getComponent(playerCamera, CTPosition3d.self),
      let aspectRatio = getComponent(playerCamera, CTAspect.self),
      let cameraScale = getComponent(playerCamera, CTScale3d.self)
    else {
      return nil
    }
    return GMCameraFirstPerson(
      transform: GEOTransform(
        position: cameraPosition.position,
        quaternion: simd_quatf(Float4x4.identity),
        scale: cameraScale.scale
      ),
      aspect: aspectRatio.aspect,
      fov: cameraComponent.fov,
      near: cameraComponent.nearPlane,
      far: cameraComponent.farPlane
    )
  }
}
