//
//  RNDRGameObject.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 12/7/25.
//
import MetalKit
import VRTMath

struct RNDRGameObject: GEOTransformable {
  let name: String
  var transform = GEOTransform()
  let model: GEOModel

  // Shortcut, until I figure out how to manage textures and colors
  let baseColor: F3

  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    params: SHDRParams
  ) {
    model.render(
      encoder: encoder,
      uniforms: uniforms,
      params: params,
      gameObject: self
    )
  }
}
