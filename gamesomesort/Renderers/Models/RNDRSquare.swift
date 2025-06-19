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

  private(set) var bufferSize: Int
  var modelMatrixBuffer: MTLBuffer? = nil
  var colorBuffer: MTLBuffer? = nil

  var bufferIndex: Int = 0

  init(bufferSize: Int = 500) {
    self.bufferSize = bufferSize
  }

  mutating func startFrame() {
    bufferIndex = 0
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

  func updateBuffers(squares: [GMSquare]) {
    guard let modelMatrixBuffer = modelMatrixBuffer, let colorBuffer = colorBuffer else { return }
    var modelMatrixPointer = modelMatrixBuffer.contents().bindMemory(to: Float4x4.self, capacity: bufferSize)
    var colorPointer = colorBuffer.contents().bindMemory(to: F4.self, capacity: bufferSize)
    squares.forEach { square in
      modelMatrixPointer.pointee = square.transform.modelMatrix
      modelMatrixPointer = modelMatrixPointer.advanced(by: 1)

      colorPointer.pointee = square.color.F4
      colorPointer = colorPointer.advanced(by: 1)
    }
  }

  mutating func updateBufferItem(square: GMSquare) {
    guard let modelMatrixBuffer = modelMatrixBuffer, let colorBuffer = colorBuffer else {
      fatalError("Oh buffer! The buffers aren't initialized!")
    }
    var modelMatrixPointer = modelMatrixBuffer.contents().bindMemory(to: Float4x4.self, capacity: bufferSize)
    modelMatrixPointer = modelMatrixPointer.advanced(by: bufferIndex)
    modelMatrixPointer.pointee = square.transform.modelMatrix

    var colorPointer = colorBuffer.contents().bindMemory(to: F4.self, capacity: bufferSize)
    colorPointer = colorPointer.advanced(by: bufferIndex)
    colorPointer.pointee = square.color.F4
    bufferIndex += 1
  }
}
