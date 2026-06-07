//
//  GCFGCreature.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/14/26.
//

import VRTMath

public struct GCFGCreature: Decodable {
  public let color: F3
  public let onWake: [GCFGOnWakeAction]
  public let model: String
  public let position: F3
  public let radius: Float
  public let rotationDegY: Float
  public let scale: Float
  public let tappable: Bool
  public let type: String
  public let visible: Bool

  public init(
    color: F3,
    onWake: [GCFGOnWakeAction],
    model: String,
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    type: String,
    visible: Bool,
  ) {
    self.color = color
    self.onWake = onWake
    self.model = model
    self.position = position
    self.radius = radius
    self.rotationDegY = rotationDegY
    self.scale = scale
    self.tappable = tappable
    self.type = type
    self.visible = visible
  }
}
