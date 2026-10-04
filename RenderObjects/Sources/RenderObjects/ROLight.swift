//
//  ROLight.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 9/30/26.
//

import VRTMath

public struct ROLight {
  public let attenuation: F3
  public let color: F3
  public let coneAngle: Float
  public let coneAttenuation: Float
  public let coneDirection: F3
  public let position: F3
  public let radius: Float
  public let specularColor: F3
  public let type: LightType

  public init(
    attenuation: F3,
    color: F3,
    coneAngle: Float,
    coneAttenuation: Float,
    coneDirection: F3,
    position: F3,
    radius: Float,
    specularColor: F3,
    type: LightType
  ) {
    self.attenuation = attenuation
    self.color = color
    self.coneAngle = coneAngle
    self.coneAttenuation = coneAttenuation
    self.coneDirection = coneDirection
    self.position = position
    self.radius = radius
    self.specularColor = specularColor
    self.type = type
  }

  public enum LightType: Int {
    case unused = 0
    case Sun = 1
    case Spot = 2
    case Point = 3
    case Ambient = 4
  }
}
