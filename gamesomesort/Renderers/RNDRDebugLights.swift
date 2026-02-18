//
//  RNDRDebugLights.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/23/25.
//

import MetalKit
import VRTMath

enum RNDRDebugLights {

  static func linePipelineStateDescriptor(
    library: MTLLibrary,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineDescriptor {
    let vertexFunction = library.makeFunction(name: "vertex_debug")
    let fragmentFunction = library.makeFunction(name: "fragment_debug_line")
    return MTLRenderPipelineDescriptor().apply {
      $0.vertexFunction = vertexFunction
      $0.fragmentFunction = fragmentFunction
      $0.colorAttachments[0].pixelFormat = colorPixelFormat
      $0.depthAttachmentPixelFormat = depthPixelFormat
    }
  }

  static func pointPipelineStateDescriptor(
    library: MTLLibrary,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat
  ) -> MTLRenderPipelineDescriptor {
    let vertexFunction = library.makeFunction(name: "vertex_debug")
    let fragmentFunction = library.makeFunction(name: "fragment_debug_point")
    return MTLRenderPipelineDescriptor().apply {
      $0.vertexFunction = vertexFunction
      $0.fragmentFunction = fragmentFunction
      $0.colorAttachments[0].pixelFormat = colorPixelFormat
      $0.depthAttachmentPixelFormat = depthPixelFormat
    }
  }

  static func draw(
    device: MTLDevice,
    lights: [SHDRLight],
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    linePipelineState: MTLRenderPipelineState,
    pointPipelineState: MTLRenderPipelineState
  ) {
    encoder.label = "Debug lights"
    for light in lights {
      switch light.type {
      case Point:
        debugDrawPoint(
          renderEncoder: encoder,
          uniforms: uniforms,
          position: light.position,
          color: light.color,
          pointPipelineState: pointPipelineState
        )
      case Spot:
        debugDrawPoint(
          renderEncoder: encoder,
          uniforms: uniforms,
          position: light.position,
          color: light.color,
          pointPipelineState: pointPipelineState
        )
        debugDrawLine(
          device: device,
          renderEncoder: encoder,
          uniforms: uniforms,
          position: light.position,
          direction: light.coneDirection,
          color: light.color,
          linePipelineState: linePipelineState,
          pointPipelineState: pointPipelineState
        )
      case Sun:
        debugDrawDirection(
          device: device,
          renderEncoder: encoder,
          uniforms: uniforms,
          direction: light.position,
          color: [1, 0, 0],
          count: 10,
          linePipelineState: linePipelineState
        )
      default:
        break
      }
    }
  }

  static func debugDrawPoint(
    renderEncoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    position: F3,
    color: F3,
    pointPipelineState: MTLRenderPipelineState
  ) {
    var vertices: [F3] = [position]
    renderEncoder.setVertexBytes(&vertices, length: MemoryLayout<F3>.stride, index: 0)
    var uniforms = uniforms
    uniforms.modelMatrix = .identity
    renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<SHDRUniforms>.stride, index: UniformsBuffer.index)
    var lightColor = color
    renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<F3>.stride, index: 1)
    // render point
    renderEncoder.setRenderPipelineState(pointPipelineState)
    renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: vertices.count)
  }

  static func debugDrawLine(
    device: MTLDevice,
    renderEncoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    position: F3,
    direction: F3,
    color: F3,
    linePipelineState: MTLRenderPipelineState,
    pointPipelineState: MTLRenderPipelineState
  ) {
    var vertices: [F3] = []
    vertices.append(position)
    vertices.append(
      F3(
        position.x + direction.x,
        position.y + direction.y,
        position.z + direction.z
      )
    )
    let buffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<F3>.stride * vertices.count, options: [])
    var uniforms = uniforms
    uniforms.modelMatrix = .identity
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<SHDRUniforms>.stride,
      index: UniformsBuffer.index
    )
    var lightColor = color
    renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<F3>.stride, index: 1)
    renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
    // render line
    renderEncoder.setRenderPipelineState(linePipelineState)
    renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertices.count)
    // render starting point
    renderEncoder.setRenderPipelineState(pointPipelineState)
    renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: 1)
  }

  static func debugDrawDirection(
    device: MTLDevice,
    renderEncoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    direction: F3,
    color: F3,
    count: Int,
    linePipelineState: MTLRenderPipelineState
  ) {
    var vertices: [F3] = []
    for index in -count..<count {
      let value = Float(index) * 0.4
      vertices.append(F3(value, value, value))
      vertices.append(
        F3(
          direction.x + value,
          direction.y + value,
          direction.z + value
        )
      )
    }

    let buffer = device.makeBuffer(bytes: &vertices, length: MemoryLayout<F3>.stride * vertices.count, options: [])
    var uniforms = uniforms
    uniforms.modelMatrix = .identity
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<SHDRUniforms>.stride,
      index: UniformsBuffer.index
    )
    var lightColor = color
    renderEncoder.setFragmentBytes(&lightColor, length: MemoryLayout<F3>.stride, index: 1)
    renderEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
    // render line
    renderEncoder.setRenderPipelineState(linePipelineState)
    renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertices.count)
  }
}
