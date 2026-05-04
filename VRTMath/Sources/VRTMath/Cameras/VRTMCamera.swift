//
//  TBDGCamera.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/3/26.
//

public protocol VRTMCamera: VRTMTransformable {
  // transform the world to camera space
  var projection: Float4x4 { get }
  // rotations and translations
  var viewMatrix: Float4x4 { get }
}
