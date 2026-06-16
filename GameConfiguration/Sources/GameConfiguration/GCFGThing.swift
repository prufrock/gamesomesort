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
  public let onWake: [GCFGOnWakeAction]
  public let position: F3
  public let radius: Float
  public let rotationDegY: Float
  public let scale: Float
  public let tappable: Bool
  public let type: ThingTypes
  public let visible: Bool

  public init(
    color: F3,
    model: String,
    onWake: [GCFGOnWakeAction],
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    type: ThingTypes,
    visible: Bool,
  ) {
    self.color = color
    self.model = model
    self.onWake = onWake
    self.position = position
    self.radius = radius
    self.rotationDegY = rotationDegY
    self.scale = scale
    self.tappable = tappable
    self.type = type
    self.visible = visible
  }

  public enum ThingTypes: String, Decodable {
    case nothing
    case playerStart
    case moveUp, moveDown, moveLeft, moveRight
  }
}
