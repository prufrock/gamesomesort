//
//  Square.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/9/25.
//

import MetalKit
import lecs_swift
import VRTMath

struct RNDRSquare {
  let v: [F3] = [  // model space
    F3(-1, 1, 0),
    F3(1, 1, 0),
    F3(1, -1, 0),
    F3(-1, -1, 0),
  ]
  let indexes: [UInt16] = [0, 1, 2, 0, 3, 2]
  let uv: [F2] = [
    F2(0.0, 0.0),
    F2(1.0, 0.0),
    F2(1.0, 1.0),
    F2(0.0, 1.0),
  ]

  var indexBuffer: MTLBuffer? = nil
  var vertexBuffer: MTLBuffer? = nil
  var uvBuffer: MTLBuffer? = nil

  private(set) var bufferSize: Int
  var modelMatrixBuffer: MTLBuffer? = nil
  var colorBuffer: MTLBuffer? = nil

  private var indexedVertexPipeline: MTLRenderPipelineState? = nil
  private var depthStencilState: MTLDepthStencilState? = nil

  init(bufferSize: Int = 500) {
    self.bufferSize = bufferSize
  }

  mutating func initBuffers(device: MTLDevice) {
    indexBuffer = device.makeBuffer(
      bytes: indexes,
      length: indexes.count * MemoryLayout<UInt16>.stride,
      options: []
    )
    vertexBuffer = device.makeBuffer(
      bytes: v,
      length: v.count * MemoryLayout<F3>.stride,
      options: []
    )
    uvBuffer = device.makeBuffer(
      bytes: uv,
      length: uv.count * MemoryLayout<F2>.stride,
      options: []
    )
    modelMatrixBuffer = device.makeBuffer(
      bytes: Array(repeating: Float4x4(), count: bufferSize),
      length: bufferSize * MemoryLayout<Float4x4>.stride,
      options: [.storageModeShared]
    )
    colorBuffer = device.makeBuffer(
      bytes: Array(repeating: F4(), count: bufferSize),
      length: bufferSize * MemoryLayout<Float4x4>.stride,
      options: [.storageModeShared]
    )
  }

  mutating func initPipelines(
    device: MTLDevice,
    library: MTLLibrary,
    pixelFormat: MTLPixelFormat
  ) {
    indexedVertexPipeline = try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "indexed_main")
        $0.fragmentFunction = library.makeFunction(name: "fragment_main")
        // TODO: should be the viewColorPixelFormat
        $0.colorAttachments[0].pixelFormat = pixelFormat
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

    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    depthStencilState = device.makeDepthStencilState(descriptor: descriptor)
  }

  mutating func updateBufferItem(square: GMSquare, bufferIndex: Int) {
    // I think I can get away without clearing the buffers on each frame, because the shader knows the number of
    // instances to draw.
    guard let modelMatrixBuffer = modelMatrixBuffer, let colorBuffer = colorBuffer else {
      fatalError("Oh buffer! The buffers aren't initialized!")
    }
    var modelMatrixPointer = modelMatrixBuffer.contents().bindMemory(to: Float4x4.self, capacity: bufferSize)
    modelMatrixPointer = modelMatrixPointer.advanced(by: bufferIndex)
    modelMatrixPointer.pointee = square.transform.modelMatrix

    var colorPointer = colorBuffer.contents().bindMemory(to: F4.self, capacity: bufferSize)
    colorPointer = colorPointer.advanced(by: bufferIndex)
    colorPointer.pointee = square.color.F4
  }

  mutating func draw(ecs: LECSWorld, encoder: MTLRenderCommandEncoder) {
    guard let indexedVertexPipeline else { return }

    var squareCount = 0
    ecs.select([LECSPosition2d.self, CTColor.self, CTRadius.self, CTTagVisible.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      let color = row.component(at: 1, columns, CTColor.self)
      let radius = row.component(at: 2, columns, CTRadius.self)
      let square = GMSquare(
        transform: GEOTransform(
          position: F3(position.position, 1.0),
          quaternion: Float4x4.identity.q,
          scale: Float3(repeating: radius.radius)
        ),
        color: color.color
      )

      updateBufferItem(square: square, bufferIndex: squareCount)
      squareCount += 1
    }

    if squareCount == 0 {
      return
    }

    let camera = ecs.gmCameraFirstPerson("playerCamera")!

    var uniforms = SHDRUniforms(
      modelMatrix: Float4x4.identity,
      viewMatrix: camera.viewMatrix,
      projectionMatrix: camera.projection,
      normalMatrix: .init(diagonal: [1, 1, 1]),
      shadowProjectionMatrix: Float4x4.identity,
      shadowViewMatrix: Float4x4.identity
    )

    encoder.setDepthStencilState(depthStencilState)
    encoder.setRenderPipelineState(indexedVertexPipeline)
    encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    encoder.setTriangleFillMode(.fill)
    encoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<SHDRUniforms>.stride,
      index: UniformsBuffer.index
    )

    encoder.setVertexBuffer(
      modelMatrixBuffer,
      offset: 0,
      index: Int(ModelMatrixBuffer.rawValue)
    )

    encoder.setFragmentBuffer(colorBuffer, offset: 0, index: Int(ColorBuffer.rawValue))

    encoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: indexes.count,
      indexType: .uint16,
      indexBuffer: indexBuffer!,
      indexBufferOffset: 0,
      instanceCount: squareCount
    )
  }
}
