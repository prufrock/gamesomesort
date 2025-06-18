//
//  CTScale3d.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/18/25.
//

import lecs_swift

struct CTScale3d: LECSComponent {
  public var scale: F3

  public var x: Float {
    get {
      scale.x
    }
    set(value) {
      scale.x = value
    }
  }

  public var y: Float {
    get {
      scale.y
    }
    set(value) {
      scale.y = value
    }
  }

  public var z: Float {
    get {
      scale.z
    }
    set(value) {
      scale.z = value
    }
  }

  public var f4x4: Float4x4 {
    get {
      Float4x4.scale(x: x, y: y, z: z)
    }
  }

  public init() {
    scale = F3(0, 0, 0)
  }

  public init(_ position: F3) {
    self.scale = position
  }

  public init(x: Float, y: Float, z: Float) {
    scale = F3(x, y, z)
  }

  public init(uniform: Float) {
    scale = F3(repeating: uniform)
  }
}
