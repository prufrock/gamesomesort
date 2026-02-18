//
//  GEOUprightable.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 12/11/25.
//

import VRTMath

protocol GEOUprightable {
  var upright: GEOTransform { get set }
}

extension GEOUprightable {
  var position: Float3 {
    get { upright.position }
    set { upright.position = newValue }
  }
  var quaternion: simd_quatf {
    get { upright.quaternion }
    set { upright.quaternion = newValue }
  }
  var scale: Float3 {
    get { upright.scale }
    set { upright.scale = newValue }
  }
}
