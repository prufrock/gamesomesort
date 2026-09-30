//
//  ROTransformable.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/26/26.
//

import simd
import VRTMath

public protocol ROTransformable {
  var transform: ROTransform { get set }
}
