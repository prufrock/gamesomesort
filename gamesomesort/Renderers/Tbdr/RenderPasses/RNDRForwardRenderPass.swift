//
//  ForwardRenderPass.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit
import lecs_swift

struct RNDRForwardRenderPass {
  let label = "Forward Render Pass"
  var descriptor: MTLRenderPassDescriptor?

  private let device: MTLDevice

  var pipelineState: MTLRenderPipelineState
  private let tbrPipelineState: MTLRenderPipelineState
  private let linePipelineState: MTLRenderPipelineState
  private let pointPipelineState: MTLRenderPipelineState
  let depthStencilState: MTLDepthStencilState?

  // model controller?
  private let sphere: GEOModel

  init(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary,
    controllerTexture: ControllerTexture
  ) {
    self.device = device

    pipelineState = Self.buildPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    tbrPipelineState = Self.buildTbrPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    linePipelineState = Self.buildLightDebugLinePipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    pointPipelineState = Self.buildLightDebugPointPipelineState(
      device: device,
      colorPixelFormat: colorPixelFormat,
      depthPixelFormat: depthPixelFormat,
      library: library
    )
    depthStencilState = Self.buildDepthStencilState(device: device)
    //sphere = GEOModel(name: "sphere", primitiveType: .sphere, controllerTexture: controllerTexture, device: device)
    sphere = GEOModel(name: "brick-sphere.usdz", controllerTexture: controllerTexture, device: device)
  }

  private static func buildPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "indexed_main")
        $0.fragmentFunction = library.makeFunction(name: "fragment_main")
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor().apply {
          // .position
          $0.attributes[Position.index].format = MTLVertexFormat.float3
          $0.attributes[Position.index].bufferIndex = VertexBuffer.index
          $0.attributes[Position.index].offset = 0
          $0.layouts[Position.index].stride = MemoryLayout<Float3>.stride
        }
      }
    )
  }

  private static func buildLightDebugLinePipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    try! device.makeRenderPipelineState(
      descriptor: RNDRDebugLights.linePipelineStateDescriptor(
        library: library,
        colorPixelFormat: colorPixelFormat,
        depthPixelFormat: depthPixelFormat
      )
    )
  }

  private static func buildLightDebugPointPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    try! device.makeRenderPipelineState(
      descriptor: RNDRDebugLights.pointPipelineStateDescriptor(
        library: library,
        colorPixelFormat: colorPixelFormat,
        depthPixelFormat: depthPixelFormat
      )
    )
  }

  private static func buildTbrPipelineState(
    device: MTLDevice,
    colorPixelFormat: MTLPixelFormat,
    depthPixelFormat: MTLPixelFormat,
    library: MTLLibrary
  ) -> MTLRenderPipelineState {
    return try! device.makeRenderPipelineState(
      descriptor: MTLRenderPipelineDescriptor().apply {
        $0.vertexFunction = library.makeFunction(name: "tbr_vertex_main")
        $0.fragmentFunction = library.makeFunction(name: "tbr_fragment_main")
        $0.colorAttachments[0].pixelFormat = colorPixelFormat
        $0.depthAttachmentPixelFormat = depthPixelFormat
        $0.vertexDescriptor = MTLVertexDescriptor.defaultLayout
      }
    )
  }

  private static func buildDepthStencilState(device: MTLDevice) -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return device.makeDepthStencilState(descriptor: descriptor)
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    ecs: LECSWorld,
    uniforms: SHDRUniforms,
    params: SHDRParams
  ) {
    guard let descriptor = descriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
    else {
      fatalError(
        "Oh sheep on the beach! Couldn't draw from the forward render pass,"
          + " because the descriptor or render encoder was nil!"
      )
    }
    renderEncoder.label = label
    renderEncoder.setDepthStencilState(depthStencilState)
    renderEncoder.setRenderPipelineState(tbrPipelineState)

    var params = params

    var sun = SHDRLight()
    sun.type = LightType(1)
    sun.color = [1, 1, 1]
    sun.position = [0, 6, -9]

    var spot = SHDRLight()
    spot.type = LightType(2)
    spot.color = [1, 0.5, 0.5]
    spot.coneDirection = [1, 1, 0]
    spot.position = [10, 7, 7]

    var point = SHDRLight()
    point.type = LightType(3)
    point.color = [0, 0.5, 0.5]
    point.position = [1, 3, 3]

    // lights...
    var lights: [SHDRLight] = [sun, spot, point]
    params.lightCount = UInt32(lights.count)

    renderEncoder.setFragmentBytes(
      &lights,
      length: MemoryLayout<SHDRLight>.stride * lights.count,
      index: LightBuffer.index
    )

    let squares = ecs.squares
    for square in squares {
      sphere.transform = square.transform
      sphere.render(
        encoder: renderEncoder,
        uniforms: uniforms,
        params: params
      )
    }

    RNDRDebugLights
      .draw(
        device: device,
        lights: lights,
        encoder: renderEncoder,
        uniforms: uniforms,
        linePipelineState: linePipelineState,
        pointPipelineState: pointPipelineState
      )
    renderEncoder.endEncoding()
  }
}

extension LECSWorld {
  fileprivate var squares: [GMSquare] {
    var squares = [GMSquare]()
    select([LECSPosition2d.self, CTColor.self, CTRadius.self, CTTagVisible.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      let color = row.component(at: 1, columns, CTColor.self)
      let radius = row.component(at: 2, columns, CTRadius.self)
      let square = GMSquare(
        transform: GEOTransform(
          position: F3(position.position, 1.0),
          quaternion: simd_quatf(Float4x4.identity),
          scale: Float3(repeating: radius.radius)
        ),
        color: color.color
      )
      squares.append(square)
    }
    return squares
  }
}

extension GEOModel {
  func render(
    encoder: MTLRenderCommandEncoder,
    uniforms: SHDRUniforms,
    params: SHDRParams
  ) {
    var uniforms = uniforms
    var params = params
    params.tiling = tiling

    uniforms.modelMatrix = transform.modelMatrix
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
