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
}
