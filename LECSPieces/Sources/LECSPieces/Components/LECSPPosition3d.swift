//
//  LECSPPosition3d.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/22/26.
//

import lecs_swift
import VRTMath

public struct LECSPPosition3d: LECSComponent {
  public var position: F3

  public var x: Float {
    get {
      position.x
    }
    set(value) {
      position.x = value
    }
  }

  public var y: Float {
    get {
      position.y
    }
    set(value) {
      position.y = value
    }
  }

  public var z: Float {
    get {
      position.z
    }
    set(value) {
      position.z = value
    }
  }

  public var xy: F2 {
    get {
      position.xy
    }
  }

  public var f4x4: Float4x4 {
    get {
      Float4x4.translate(x: x, y: y, z: z)
    }
  }

  public init() {
    position = F3(0, 0, 0)
  }

  public init(_ position: F3) {
    self.position = position
  }

  public init(_ x: Float, _ y: Float, _ z: Float) {
    position = F3(x, y, z)
  }

  public init(x: Float, y: Float, z: Float) {
    self.init(x, y, z)
  }
}

public extension LECSPPosition3d {
  static func + (lhs: LECSPPosition3d, rhs: F3) -> LECSPPosition3d {
    return LECSPPosition3d(lhs.position + rhs)
  }
}
