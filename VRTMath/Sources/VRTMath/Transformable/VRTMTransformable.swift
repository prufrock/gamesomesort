//
//  VRTMTransformable.swift
//  VRTMath
//
//  Created by David Kanenwisher on 5/3/26.
//

import simd

/// The VRTMTransformable protocol defines a type exposing the
/// necessary attributes to be transformed in 3D space. This is
/// useful for game space calculations and rendering.
public protocol VRTMTransformable {
  var transform: VRTMTransform { get set }
}

public extension VRTMTransformable {
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
