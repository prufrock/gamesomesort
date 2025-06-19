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

  private var squareRenderer = RNDRSquare()

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

    squareRenderer.initBuffers(device: device)
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

    squareRenderer.startFrame()

    var squareCount = 0
    ecs.select([LECSPosition2d.self, CTColor.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      let color = row.component(at: 1, columns, CTColor.self)
      let square = GMSquare(
        transform: GEOTransform(
          position: F3(position.position, 1.0),
          quaternion: simd_quatf(Float4x4.identity),
          scale: Float3(0.5, 0.5, 0.5)
        ),
        color: color.color
      )

      squareRenderer.updateBufferItem(square: square)
      squareCount += 1
    }

    let camera = ecs.gmCameraFirstPersion("playerCamera")!

    var uniforms = RNDRUniforms(
      viewMatrix: camera.viewMatrix,
      projectionMatrix: camera.projection
    )

    encoder.setRenderPipelineState(indexedVertexPipeline)
    encoder.setVertexBuffer(squareRenderer.vertexBuffer, offset: 0, index: 0)
    encoder.setTriangleFillMode(.fill)
    encoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<RNDRUniforms>.stride,
      index: UniformsBuffer.index
    )

    encoder.setVertexBuffer(
      squareRenderer.modelMatrixBuffer,
      offset: 0,
      index: Int(ModelMatrixBuffer.rawValue)
    )

    encoder.setFragmentBuffer(squareRenderer.colorBuffer, offset: 0, index: Int(ColorBuffer.rawValue))

    encoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: squareRenderer.indexes.count,
      indexType: .uint16,
      indexBuffer: squareRenderer.indexBuffer!,
      indexBufferOffset: 0,
      instanceCount: squareCount
    )
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
