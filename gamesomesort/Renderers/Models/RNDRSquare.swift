//
//  Square.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/9/25.
//

import MetalKit

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
  }
}
