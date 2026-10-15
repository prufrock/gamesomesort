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
  let gameObjects: [RNDRGameObject]
  // Group models together, so they can use instanced renderering
  let modelKeys: Set<String>
  let modelKeysInstanced: Set<String>
  let modelGroups: [String: [RNDRGameObject]]
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
    var tempModelGroups: [String: [RNDRGameObject]] = [:]
    var tempModelGroupTransforms: [String: [Float4x4]] = [:]
    var tempModelGroupBaseColors: [String: [F3]] = [:]
    gameObjects = scene.gameObjects.map {
      let robj = RNDRGameObject(
        name: $0.name,
        // might not need with tempModelGroupTransforms
        transform: GEOTransform(
          position: $0.transform.position,
          quaternion: $0.transform.quaternion,
          scale: $0.transform.scale
        ),
        model: controllerModel.models[$0.name]!,
        baseColor: $0.color
      )

      if robj.model.renderInstanced {
        tempModelKeysInstanced.insert(robj.model.name)
      } else {
        tempModelKeys.insert(robj.model.name)
      }
      tempModelGroups[robj.model.name, default: []].append(robj)
      tempModelGroupTransforms[robj.model.name, default: []].append(
        (robj.transform.modelMatrix * robj.model.upright.modelMatrix)
      )
      tempModelGroupBaseColors[robj.model.name, default: []].append(
        robj.baseColor
      )

      return robj
    }
    self.modelKeys = tempModelKeys
    self.modelKeysInstanced = tempModelKeysInstanced
    self.modelGroups = tempModelGroups
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
    renderPass: RNDRTiledDeferredRenderPass
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
