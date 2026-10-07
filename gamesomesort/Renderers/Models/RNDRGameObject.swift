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
    scene: RNDRScene
  ) {
    var uniforms = scene.uniforms
    var params = scene.params

    let baseColor: F3? = baseColor
    let transforms = transform * model.upright

    if let baseColor {
      model.meshes[0].submeshes[0].material.baseColor = baseColor
    }

    uniforms.modelMatrix = transforms.modelMatrix
    uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

    encoder.setVertexBytes(&uniforms, length: MemoryLayout<SHDRUniforms>.stride, index: UniformsBuffer.index)

    encoder.setFragmentBytes(&params, length: MemoryLayout<SHDRParams>.stride, index: ParamsBuffer.index)

    for mesh in model.meshes {
      for (index, verteBuffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(verteBuffer, offset: 0, index: index)
      }

      for submesh in mesh.submeshes {

        var material = submesh.material
        encoder.setFragmentBytes(&material, length: MemoryLayout<SHDRMaterial>.stride, index: MaterialBuffer.index)

        encoder.setFragmentTexture(submesh.textures.baseColor, index: BaseColor.index)
        encoder.setFragmentTexture(submesh.textures.normal, index: NormalTexture.index)
        encoder.setFragmentTexture(submesh.textures.roughness, index: RoughnessTexture.index)
        encoder.setFragmentTexture(submesh.textures.metallic, index: MetallicTexture.index)
        encoder.setFragmentTexture(submesh.textures.aoTexture, index: AOTexture.index)
        // Being explicit for a little bit, because of an unexpected issue with stencils...
        encoder.setFrontFacing(.clockwise)
        encoder.setCullMode(.back)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset
        )
      }
    }
  }
}

extension Array where Element == RNDRGameObject {
  func render(
    encoder: MTLRenderCommandEncoder,
    scene: RNDRScene
  ) {
    self.forEach { gameObject in
      encoder.pushDebugGroup("model \(gameObject.name)")
      gameObject.render(encoder: encoder, scene: scene)
      encoder.popDebugGroup()
    }
  }
}
