//
//  GMCamera.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import VRTMath

protocol GMCamera: GEOTransformable {
  // transform the world to camera space
  var projection: Float4x4 { get }
  // rotations and translations
  var viewMatrix: Float4x4 { get }
}
