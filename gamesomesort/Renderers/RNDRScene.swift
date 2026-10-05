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
  private let controllerModel: ControllerModel

  var cameraPlayerOne: GMCameraFirstPerson {
    GMCameraFirstPerson(camera: scene.cameraPlayerOne)
  }
  let gameObjects: [RNDRGameObject]

  var lights: [ROLight] {
    scene.lights
  }
  var params: SHDRParams = SHDRParams()
  var uniforms: SHDRUniforms = SHDRUniforms()
  var upVector: F3 {
    scene.upVector
  }

  init(
    scene: ROScene,
    controllerModel: ControllerModel
  ) {
    self.scene = scene
    self.controllerModel = controllerModel

    gameObjects = scene.gameObjects.map {
      RNDRGameObject(
        name: $0.name,
        transform: GEOTransform(
          position: $0.transform.position,
          quaternion: $0.transform.quaternion,
          scale: $0.transform.scale
        ),
        model: controllerModel.models[$0.name]!,
        baseColor: $0.color
      )
    }

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
