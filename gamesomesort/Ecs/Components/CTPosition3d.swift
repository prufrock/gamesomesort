//
//  CTPosition3d.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift
import VRTMath

struct CTPosition3d: LECSComponent {
  var position: F3

  var x: Float {
    get {
      position.x
    }
    set(value) {
      position.x = value
    }
  }

  var y: Float {
    get {
      position.y
    }
    set(value) {
      position.y = value
    }
  }

  var z: Float {
    get {
      position.z
    }
    set(value) {
      position.z = value
    }
  }

  var xy: F2 {
    get {
      position.xy
    }
  }

  var f4x4: Float4x4 {
    get {
      Float4x4.translate(x: x, y: y, z: z)
    }
  }

  init() {
    position = F3(0, 0, 0)
  }

  init(_ position: F3) {
    self.position = position
  }

  init(_ x: Float, _ y: Float, _ z: Float) {
    position = F3(x, y, z)
  }

  init(x: Float, y: Float, z: Float) {
    self.init(x, y, z)
  }
}

extension CTPosition3d {
  static func + (lhs: CTPosition3d, rhs: F3) -> CTPosition3d {
    return CTPosition3d(lhs.position + rhs)
  }
}
