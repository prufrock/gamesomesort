//
//  RNDRScene.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 9/30/26.
//

import Metal
import RenderObjects
import VRTMath

struct RNDRScene {
  private let scene: ROScene
  // find a way to avoid making this public
  let controllerModel: ControllerModel

  var cameraPlayerOne: GMCameraFirstPerson {
    GMCameraFirstPerson(camera: scene.cameraPlayerOne)
  }
  // Group models together, so they can use instanced renderering
  let modelKeys: Set<String>
  let modelKeysInstanced: Set<String>
  let modelGroupTransforms: [String: [Float4x4]]
  let modelGroupBaseColors: [String: [F3]]

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
    controllerModel: ControllerModel,
    device: MTLDevice
  ) {
    self.scene = scene
    self.controllerModel = controllerModel

    var tempModelKeys: Set<String> = []
    var tempModelKeysInstanced: Set<String> = []
    var tempModelGroupTransforms: [String: [Float4x4]] = [:]
    var tempModelGroupBaseColors: [String: [F3]] = [:]
    scene.gameObjects.forEach {
      let transform = GEOTransform(
        position: $0.transform.position,
        quaternion: $0.transform.quaternion,
        scale: $0.transform.scale
      )
      let model = controllerModel.models[$0.name]!

      if model.renderInstanced {
        tempModelKeysInstanced.insert(model.name)
      } else {
        tempModelKeys.insert(model.name)
      }
      tempModelGroupTransforms[model.name, default: []].append(
        (transform.modelMatrix * model.upright.modelMatrix)
      )
      tempModelGroupBaseColors[model.name, default: []].append(
        $0.color
      )
    }
    self.modelKeys = tempModelKeys
    self.modelKeysInstanced = tempModelKeysInstanced
    self.modelGroupTransforms = tempModelGroupTransforms
    tempModelKeysInstanced.forEach { key in
      let transforms = tempModelGroupTransforms[key]!
      controllerModel.updateTransformsBuffer(forModel: key, with: transforms)
    }
    self.modelGroupBaseColors = tempModelGroupBaseColors

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

  func render(
    encoder: MTLRenderCommandEncoder,
    renderPass: RNDRPassRendersSingleOrInstancedEncoder
  ) {
    renderPass.renderIndividual(renderEncoder: encoder)
    modelKeys.forEach { modelName in
      if let model = controllerModel.models[modelName] {
        for (index, transform) in modelGroupTransforms[model.name]!.enumerated() {
          model.render(
            encoder: encoder,
            scene: self,
            transform: transform,
            baseColor: modelGroupBaseColors[model.name]![index]
          )
        }
      }
    }
    renderPass.renderInstanced(renderEncoder: encoder)
    modelKeysInstanced.forEach { modelName in
      if let model = controllerModel.models[modelName] {
        model.renderInstanced(encoder: encoder, scene: self)
      }
    }
  }
}
