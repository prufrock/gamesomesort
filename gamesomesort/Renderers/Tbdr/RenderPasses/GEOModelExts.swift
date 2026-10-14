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
    scene: RNDRScene,
    gameObject: RNDRGameObject? = nil
  ) {
    let baseColor: F3 = gameObject?.baseColor ?? [1, 1, 1]
    let transform = ((gameObject?.transform ?? GEOTransform()) * self.upright).modelMatrix
    render(encoder: encoder, scene: scene, transform: transform, baseColor: baseColor)
  }

  func render(
    encoder: MTLRenderCommandEncoder,
    scene: RNDRScene,
    transform: Float4x4,
    baseColor: F3
  ) {
    var uniforms = scene.uniforms
    var params = scene.params

    meshes[0].submeshes[0].material.baseColor = baseColor

    uniforms.modelMatrix = transform
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

  func renderInstanced(
    encoder: MTLRenderCommandEncoder,
    scene: RNDRScene,
  ) {
    var uniforms = scene.uniforms
    var params = scene.params
    let transforms = scene.modelGroupTransforms[name]!
    var modelGroupBaseColors = scene.modelGroupBaseColors[name]!

    encoder.setVertexBytes(&uniforms, length: MemoryLayout<SHDRUniforms>.stride, index: UniformsBuffer.index)
    encoder.setVertexBytes(
      transforms,
      length: MemoryLayout<Float4x4>.stride * transforms.count,
      index: ModelMatrixBuffer.index
    )

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
        encoder.setFragmentBytes(
          &modelGroupBaseColors,
          length: MemoryLayout<Float3>.stride * modelGroupBaseColors.count,
          index: ColorBuffer.index
        )
        // Being explicit for a little bit, because of an unexpected issue with stencils...
        encoder.setFrontFacing(.clockwise)
        encoder.setCullMode(.back)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset,
          instanceCount: transforms.count
        )
      }
    }
  }
}
