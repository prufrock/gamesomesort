//
//  GCFGTile.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/14/26.
//

import VRTMath

public struct GCFGTile: Decodable {
  public let color: F3
  public let model: String
  public let name: String
  public let radius: Float
  public let rotationDegY: Float
  public let scale: Float
  public let tappable: Bool
  public let visible: Bool
  public let z: Float

  public init(
    color: F3,
    model: String,
    name: String,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool,
    z: Float
  ) {
    self.color = color
    self.model = model
    self.name = name
    self.radius = radius
    self.rotationDegY = rotationDegY
    self.scale = scale
    self.tappable = tappable
    self.visible = visible
    self.z = z
  }
}
