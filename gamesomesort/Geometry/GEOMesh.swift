//
//  GEOMesh.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/15/25.
//

import MetalKit

struct GEOMesh {
  var vertexBuffers: [MTLBuffer]
  var submeshes: [GEOSubmesh]

  init(mdlMesh: MDLMesh, mtkMesh: MTKMesh, controllerTexture: ControllerTexture, device: MTLDevice) {
    var vertexBuffers: [MTLBuffer] = []
    for mtkMeshBuffer in mtkMesh.vertexBuffers {
      vertexBuffers.append(mtkMeshBuffer.buffer)
    }
    self.vertexBuffers = vertexBuffers
    submeshes = zip(mdlMesh.submeshes!, mtkMesh.submeshes).map { mesh in
      GEOSubmesh(
        mdlSubmesh: mesh.0 as! MDLSubmesh,
        mtkSubmesh: mesh.1,
        textureController: controllerTexture,
        device: device
      )
    }
  }
}
