//
//  VertexDescriptorExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()

    // Position and Normal are packed next to each with an offset
    var offset = 0
    vertexDescriptor.attributes[Position.index] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: VertexBuffer.index
    )
    offset += MemoryLayout<Float3>.stride

    vertexDescriptor.attributes[Normal.index] = MDLVertexAttribute(
      name: MDLVertexAttributeNormal,
      format: .float3,
      offset: offset,
      bufferIndex: VertexBuffer.index
    )
    offset += MemoryLayout<Float3>.stride
    vertexDescriptor.layouts[VertexBuffer.index] = MDLVertexBufferLayout(stride: offset)

    // UVs
    vertexDescriptor.attributes[UV.index] = MDLVertexAttribute(
      name: MDLVertexAttributeTextureCoordinate,
      format: .float2,
      offset: 0,
      bufferIndex: UVBuffer.index
    )
    vertexDescriptor.layouts[UVBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<Float2>.stride)

    // Tangents
    vertexDescriptor.attributes[Tangent.index] = MDLVertexAttribute(
      name: MDLVertexAttributeTangent,
      format: .float3,
      offset: 0,
      bufferIndex: TangentBuffer.index
    )
    vertexDescriptor.layouts[TangentBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<Float3>.stride)

    // Bitangents
    vertexDescriptor.attributes[Bitangent.index] = MDLVertexAttribute(
      name: MDLVertexAttributeBitangent,
      format: .float3,
      offset: 0,
      bufferIndex: BitangentBuffer.index
    )
    vertexDescriptor.layouts[BitangentBuffer.index] = MDLVertexBufferLayout(stride: MemoryLayout<Float3>.stride)

    return vertexDescriptor
  }
}
