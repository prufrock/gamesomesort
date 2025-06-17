//
//  RNDRSquareRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/4/25.
//

import MetalKit
import lecs_swift

///  At what point does the processing required to load the renderer require putting it behind a loading screen?
class RNDRSquareRenderer: RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

  private let indexedVertexPipeline: MTLRenderPipelineState

  private var square = RNDRSquare()

  private var size: CGSize = .zero
  private var aspectRatio: Float = 1.0

  init(config: AppCoreConfig) {
    self.config = config

    guard let newDevice = MTLCreateSystemDefaultDevice() else {
      fatalError(
        """
        I looked in the computer and didn't find a device...sorry
        """
      )
    }
    device = newDevice

    guard let newCommandQueue = device.makeCommandQueue() else {
      fatalError(
        """
        What?! No comand queue. Come on!
        """
      )
    }

    commandQueue = newCommandQueue

    guard let library = device.makeDefaultLibrary() else {
      fatalError(
        """
        Heckin' A! The library didn't load!
        """
      )
    }

    indexedVertexPipeline = try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "indexed_main")
        $0.fragmentFunction = library.makeFunction(name: "fragment_main")
        // TODO: should be the viewColorPixelFormat
        $0.colorAttachments[0].pixelFormat = .bgra8Unorm
        $0.vertexDescriptor = MTLVertexDescriptor().apply {
          // .position
          $0.attributes[Position.index].format = MTLVertexFormat.float3
          $0.attributes[Position.index].bufferIndex = VertexBuffer.index
          $0.attributes[Position.index].offset = 0
          $0.layouts[Position.index].stride = MemoryLayout<Float3>.stride
        }
      }
    )

    square.initBuffers(device: device)
  }

  func resize(size newSize: CGSize) {
    size = newSize
    aspectRatio = size.aspectRatio().f
  }

  func render(ecs: LECSWorld, to renderDescriptor: RenderDescriptor) {
    guard let commandBuffer = commandQueue.makeCommandBuffer() else {
      fatalError(
        """
        Ugh, no command buffer. They must be fresh out!
        """
      )
    }

    guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDescriptor.currentRenderPassDescriptor)
    else {
      fatalError(
        """
        Dang it, couldn't create a command encoder.
        """
      )
    }

    var positions: [LECSPosition2d] = []
    ecs.select([LECSPosition2d.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      positions.append(position)
    }

    var uniforms = RNDRUniforms(
      viewMatrix: Float4x4.identity,
      projectionMatrix: Float4x4.identity.perspectiveProjection(
        fov: .pi / 2,
        aspect: aspectRatio,
        nearPlane: 0.1,
        farPlane: 20
      )
    )
    let finalTransforms: [Float4x4] = positions.map {
      Float4x4.identity.translate(position: Float3($0.x, $0.y, 1.0)).scaleUniform(0.25)
    }

    finalTransforms.chunked(into: 64).forEach { chunk in
      encoder.setRenderPipelineState(indexedVertexPipeline)
      encoder.setVertexBuffer(square.vertexBuffer, offset: 0, index: 0)
      encoder.setTriangleFillMode(.fill)
      encoder.setVertexBytes(
        &uniforms,
        length: MemoryLayout<RNDRUniforms>.stride,
        index: UniformsBuffer.index
      )
      encoder.setVertexBytes(
        chunk,
        length: MemoryLayout<Float4x4>.stride * chunk.count,
        index: ModelMatrixBuffer.index
      )

      var fragmentColor = Float4(1, 0, 0, 1)

      encoder.setFragmentBuffer(square.vertexBuffer, offset: 0, index: 0)
      encoder.setFragmentBytes(&fragmentColor, length: MemoryLayout<Float4>.stride, index: 0)

      encoder.drawIndexedPrimitives(
        type: .triangle,
        indexCount: square.indexes.count,
        indexType: .uint16,
        indexBuffer: square.indexBuffer!,
        indexBufferOffset: 0,
        instanceCount: chunk.count
      )
    }
    encoder.endEncoding()
    commandBuffer.present(renderDescriptor.currentDrawable)
    commandBuffer.commit()
  }
}

extension AppCoreConfig.Services.RenderService {
  var mtlClearColor: MTLClearColor {
    .init(red: clearColor.0, green: clearColor.1, blue: clearColor.2, alpha: clearColor.3)
  }
}
