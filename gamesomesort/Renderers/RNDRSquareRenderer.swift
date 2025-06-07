//
//  RNDRSquareRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/4/25.
//

import MetalKit

///  At what point does the processing required to load the renderer require putting it behind a loading screen?
class RNDRSquareRenderer: RNDRRenderer {
  private let config: AppCoreConfig
  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue

  private let indexedVertexPipeline: MTLRenderPipelineState

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
        $0.colorAttachments[0].pixelFormat = .bgra8Unorm
        $0.depthAttachmentPixelFormat = .depth32Float
        $0.vertexDescriptor = MTLVertexDescriptor().apply {
          // .position
          $0.attributes[Position.index].format = MTLVertexFormat.float3
          $0.attributes[Position.index].bufferIndex = VertexBuffer.index
          $0.attributes[Position.index].offset = 0
          $0.layouts[Position.index].stride = MemoryLayout<Float3>.stride
        }
      }
    )

    commandQueue = newCommandQueue
  }

  func resize(view: MTKView, size: CGSize) {
    // no-op
  }

  func render(to renderDescriptor: RenderDescriptor) {
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
