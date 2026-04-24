//
//  LECSPQuaternion.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/23/26.
//

import lecs_swift
import VRTMath
import simd

public struct LECSPQuaternion: LECSComponent {
  public var quaternion: simd_quatf

  public init() {
    self.quaternion = .init(Float4x4.identity)
  }

  public init(_ quaternion: simd_quatf) {
    self.quaternion = quaternion
  }
}
