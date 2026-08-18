//
//  GEOModelExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/17/26.
//

import MetalKit
import VRTMath

extension GEOModel {
  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    params: SHDRParams,
    gameObject: RNDRGameObject? = nil
  ) {
    var uniforms = uniforms
    var params = params

    let baseColor: F3? = gameObject?.baseColor
    let transforms = (gameObject?.transform ?? GEOTransform()) * self.upright

    if let baseColor {
      meshes[0].submeshes[0].material.baseColor = baseColor
    }

    uniforms.modelMatrix = transforms.modelMatrix
    uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

    encoder.setVertexBytes(&uniforms, length: MemoryLayout<SHDRUniforms>.stride, index: UniformsBuffer.index)

    encoder.setFragmentBytes(&params, length: MemoryLayout<SHDRParams>.stride, index: ParamsBuffer.index)

    for mesh in meshes {
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
