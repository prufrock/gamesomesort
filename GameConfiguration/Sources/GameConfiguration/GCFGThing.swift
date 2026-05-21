//
//  GCFGThing.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

import VRTMath

public struct GCFGThing: Decodable {
  public let color: F3
  public let model: String
  public let type: ThingTypes
  public let radius: Float
  public let rotationDegY: Float
  public let scale: Float
  public let tappable: Bool
  public let visible: Bool
  public let z: Float

  public init(
    color: F3,
    model: String,
    type: ThingTypes,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool,
    z: Float
  ) {
    self.color = color
    self.model = model
    self.type = type
    self.radius = radius
    self.rotationDegY = rotationDegY
    self.scale = scale
    self.tappable = tappable
    self.visible = visible
    self.z = z
  }

  public enum ThingTypes: String, Decodable {
    case nothing
    case playerStart
  }
}
