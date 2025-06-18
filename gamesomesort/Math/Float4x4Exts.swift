//
//  Float4x4Exts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/9/25.
//

typealias Float4x4 = simd_float4x4

extension Float4x4 {
  static var identity: Float4x4 {
    matrix_identity_float4x4
  }

  static func scale(x: Float, y: Float, z: Float) -> Float4x4 {
    Float4x4(
      [x, 0, 0, 0],
      [0, y, 0, 0],
      [0, 0, z, 0],
      [0, 0, 0, 1]
    )
  }

  func scale(x: Float, y: Float, z: Float) -> Float4x4 {
    self * Self.scale(x: x, y: y, z: z)
  }

  static func scale(_ value: Float) -> Float4x4 {
    return Self.scale(x: value, y: value, z: value)
  }

  func scale(_ value: Float) -> Float4x4 {
    self * Self.scale(x: value, y: value, z: value)
  }

  static func scale(_ value: Float3) -> Float4x4 {
    return Self.scale(x: value.x, y: value.y, z: value.z)
  }

  func scale(_ value: Float3) -> Float4x4 {
    self * Self.scale(x: value.x, y: value.y, z: value.z)
  }

  static func scaleX(_ x: Float) -> Float4x4 {
    scale(x: x, y: 1, z: 1)
  }

  func scaleX(_ x: Float) -> Float4x4 {
    self * Self.scaleX(x)
  }

  static func scaleY(_ y: Float) -> Float4x4 {
    scale(x: 1, y: y, z: 1)
  }

  func scaleY(_ y: Float) -> Float4x4 {
    self * Self.scaleY(y)
  }

  static func scaleZ(_ z: Float) -> Float4x4 {
    scale(x: 1, y: 1, z: z)
  }

  func scaleZ(_ z: Float) -> Float4x4 {
    self * Self.scaleZ(z)
  }

  static func scaleUniform(_ v: Float) -> Float4x4 {
    Float4x4(
      [v, 0, 0, 0],
      [0, v, 0, 0],
      [0, 0, v, 0],
      [0, 0, 0, 1]
    )
  }

  func scaleUniform(_ v: Float) -> Float4x4 {
    self * Self.scaleUniform(v)
  }

  static func translate(x: Float, y: Float, z: Float) -> Float4x4 {
    Float4x4(
      [1, 0, 0, 0],
      [0, 1, 0, 0],
      [0, 0, 1, 0],
      [x, y, z, 1]
    )
  }

  static func translate(_ position: Float3) -> Float4x4 {
    Self.translate(x: position.x, y: position.y, z: position.z)
  }

  func translate(_ position: Float3) -> Float4x4 {
    self * Self.translate(position)
  }

  // Rotate about the X axis with Euler angles
  static func rotateX(_ angle: Float) -> Float4x4 {
    Float4x4(
      [1, 0, 0, 0],
      [0, cos(angle), sin(angle), 0],
      [0, -sin(angle), cos(angle), 0],
      [0, 0, 0, 1]
    )
  }

  func rotateX(_ angle: Float) -> Float4x4 {
    self * Self.rotateX(angle)
  }

  // Rotate about the Y axes with Euler angles.
  static func rotateY(_ angle: Float) -> Float4x4 {
    Float4x4(
      [cos(angle), 0, -sin(angle), 0],
      [0, 1, 0, 0],
      [sin(angle), 0, cos(angle), 0],
      [0, 0, 0, 1]
    )
  }

  func rotateY(_ angle: Float) -> Float4x4 {
    self * Self.rotateY(angle)
  }

  // Rotate about the Z axes with Euler angles.
  static func rotateZ(_ angle: Float) -> Float4x4 {
    Float4x4(
      [cos(angle), sin(angle), 0, 0],
      [-sin(angle), cos(angle), 0, 0],
      [0, 0, 1, 0],
      [0, 0, 0, 1]
    )
  }

  func rotateZ(_ angle: Float) -> Float4x4 {
    self * Self.rotateZ(angle)
  }

  /// Rotate in heading pitch bank order
  static func rotate(_ angles: Float3) -> Float4x4 {
    rotateY(angles.y) * rotateX(angles.x) * rotateZ(angles.z)
  }

  func rotate(_ angles: Float3) -> Float4x4 {
    self * Self.rotate(angles)
  }

  static func rotate(_ quaternion: simd_quatf) -> Float4x4 {
    return Float4x4(quaternion)
  }

  func rotate(_ quaternion: simd_quatf) -> Float4x4 {
    self * Self.rotate(quaternion)
  }

  static func perspectiveProjection(fov: Float, aspect: Float, nearPlane: Float, farPlane: Float) -> Float4x4 {
    let zoom = 1 / tan(fov / 2)  // objects get smaller as fov increases

    // Figure out the individual values
    let y = zoom
    let x = y / aspect
    let z = farPlane / (farPlane - nearPlane)
    let w = -nearPlane * z

    // Initialize the columns
    let X = Float4(x, 0, 0, 0)
    let Y = Float4(0, y, 0, 0)
    let Z = Float4(0, 0, z, 1)
    let W = Float4(0, 0, w, 0)

    // Create the projection from the columns
    return Float4x4(X, Y, Z, W)
  }

  func perspectiveProjection(fov: Float, aspect: Float, nearPlane: Float, farPlane: Float) -> Float4x4 {
    self * Self.perspectiveProjection(fov: fov, aspect: aspect, nearPlane: nearPlane, farPlane: farPlane)
  }
}
