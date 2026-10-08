//
//  GEOModel.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit

class GEOModel: GEOUprightable {
  var upright = GEOTransform()
  var meshes: [GEOMesh] = []
  let name: String
  let renderInstanced: Bool

  /// Create a new GEOModel instance.
  /// - Parameters:
  ///   - name: The name of the model.
  ///   - controllerTexture: The texture controller to read textures from.
  ///   - device: The device used to load and render the model.
  ///   - upright: The transformation needed to bring the model into upright space.
  ///   - renderInstanced: Whether to use instanced render.
  init(
    name: String,
    controllerTexture: ControllerTexture,
    device: MTLDevice,
    upright: GEOTransform,
    renderInstanced: Bool
  ) {
    guard let assertUrl = Bundle.main.url(forResource: name, withExtension: nil) else {
      fatalError("Model \(name) not found")
    }
    let allocator = MTKMeshBufferAllocator(device: device)
    let asset = MDLAsset(url: assertUrl, vertexDescriptor: .defaultLayout, bufferAllocator: allocator)
    asset.loadTextures()
    var mtkMeshes: [MTKMesh] = []
    let mdlMeshes = asset.childObjects(of: MDLMesh.self) as? [MDLMesh] ?? []
    _ = mdlMeshes.map { mdlMesh in
      mdlMesh.addTangentBasis(
        forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
        tangentAttributeNamed: MDLVertexAttributeTangent,
        bitangentAttributeNamed: MDLVertexAttributeBitangent
      )
      mtkMeshes.append(
        try! MTKMesh(mesh: mdlMesh, device: device)
      )
    }
    meshes = zip(mdlMeshes, mtkMeshes).map {
      GEOMesh(mdlMesh: $0.0, mtkMesh: $0.1, controllerTexture: controllerTexture, device: device)
    }
    self.name = name
    self.upright = upright
    self.renderInstanced = renderInstanced
  }

  // Initialize a model that uses a primitive
  init(
    name: String,
    primitiveType: GEOPrimitive,
    controllerTexture: ControllerTexture,
    device: MTLDevice,
    upright: GEOTransform,
    renderInstanced: Bool
  ) {
    precondition(!name.isEmpty, "Name must not be empty")
    let mdlMesh = Self.createMesh(primitiveType: primitiveType, device: device)
    mdlMesh.vertexDescriptor = MDLVertexDescriptor.defaultLayout
    mdlMesh.addTangentBasis(
      forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate,
      tangentAttributeNamed: MDLVertexAttributeTangent,
      bitangentAttributeNamed: MDLVertexAttributeBitangent
    )
    let mtkMesh = try! MTKMesh(mesh: mdlMesh, device: device)
    let mesh = GEOMesh(mdlMesh: mdlMesh, mtkMesh: mtkMesh, controllerTexture: controllerTexture, device: device)
    self.meshes = [mesh]
    self.name = name
    self.upright = upright
    self.renderInstanced = renderInstanced
  }

  func setTexture(name: String, type: SHDRTextureIndices, controllerTexture: ControllerTexture, device: MTLDevice) {
    if let texture = controllerTexture.loadTexture(name: name, device: device) {
      switch type {
      case BaseColor:
        meshes[0].submeshes[0].textures.baseColor = texture
      default:
        break
      }
    }
  }
}

enum GEOPrimitive {
  case plane, sphere, icosahedron
}


extension GEOModel {
  static func createMesh(primitiveType: GEOPrimitive, device: MTLDevice) -> MDLMesh {
    let allocator = MTKMeshBufferAllocator(device: device)
    switch primitiveType {
    case .icosahedron:
      return MDLMesh(
        icosahedronWithExtent: [1, 1, 1],
        inwardNormals: false,
        geometryType: .triangles,
        allocator: allocator
      )
    case .plane:
      return MDLMesh(
        planeWithExtent: [1, 1, 1],
        segments: [4, 4],
        geometryType: .triangles,
        allocator: allocator
      )
    case .sphere:
      return MDLMesh(
        sphereWithExtent: [1, 1, 1],
        segments: [30, 30],
        inwardNormals: false,
        geometryType: .triangles,
        allocator: allocator
      )
    }
  }
}
