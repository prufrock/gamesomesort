//
//  GEOTransformable.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import VRTMath

protocol GEOTransformable {
  var transform: GEOTransform { get set }
}

extension GEOTransformable {
  var position: Float3 {
    get { transform.position }
    set { transform.position = newValue }
  }
  var quaternion: simd_quatf {
    get { transform.quaternion }
    set { transform.quaternion = newValue }
  }
  var scale: Float3 {
    get { transform.scale }
    set { transform.scale = newValue }
  }
}
