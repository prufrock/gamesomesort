//
//  CTQuaternion.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/10/25.
//

import lecs_swift

struct CTQuaternion: LECSComponent {
  var quaternion: simd_quatf

  init() {
    self.quaternion = .init(Float4x4.identity)
  }

  init(_ quaternion: simd_quatf) {
    self.quaternion = quaternion
  }
}
