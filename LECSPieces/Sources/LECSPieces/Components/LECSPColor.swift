//
//  LECSPColor.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/23/26.
//

import lecs_swift
import VRTMath

public struct LECSPColor: LECSComponent {
  public var color: VRTMColorA

  public var f3: Float3 {
    Float3(x: color.r, y: color.g, z: color.b)
  }

  public init() {
    let temp: VRTMColor = .white
    color = temp.a()
  }

  public init(color: VRTMColorA) {
    self.color = color
  }

  public init(_ color: VRTMColor, a: Float = 1.0) {
    self.color = color.a(a)
  }

  public init(_ color: Float3) {
    self.color = .init(r: color.x, g: color.y, b: color.z, a: 1.0)
  }
}
