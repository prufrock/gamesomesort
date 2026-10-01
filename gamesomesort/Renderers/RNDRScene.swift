//
//  RNDRScene.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/30/26.
//

import RenderObjects
import VRTMath

struct RNDRScene {
  private let scene: ROScene

  var cameraPlayerOne: GMCameraFirstPerson {
    GMCameraFirstPerson(camera: scene.cameraPlayerOne)
  }
  var params: SHDRParams = SHDRParams()
  var uniforms: SHDRUniforms = SHDRUniforms()
  var upVector: F3 {
    scene.upVector
  }

  init(scene: ROScene) {
    self.scene = scene

    uniforms.viewMatrix = cameraPlayerOne.viewMatrix
    uniforms.projectionMatrix = cameraPlayerOne.projection

    let shadowCamera = cameraPlayerOne.createShadowCamera(lightPosition: scene.sun.position)
    uniforms.shadowProjectionMatrix = shadowCamera.projection
    uniforms.shadowViewMatrix =
      Float4x4.scale(cameraPlayerOne.scale)
      * Float4x4.lookAtProjection(
        eye: shadowCamera.position,
        center: shadowCamera.center,
        up: scene.upVector
      )

    self.params = SHDRParams(lightCount: 0, cameraPosition: cameraPlayerOne.position)
  }
}
