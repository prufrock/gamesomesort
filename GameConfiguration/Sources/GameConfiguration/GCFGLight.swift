//
//  GCFGLight.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 7/8/26.
//

import VRTMath

public struct GCFGLight: Decodable {
  public let attenuation: F3
  public let color: F3
  public let position: F3
  public let specularColor: Float
  public let type: LightType

  public init(
    attenuation: F3,
    color: F3,
    position: F3,
    specularColor: Float,
    type: LightType
  ) {
    self.attenuation = attenuation
    self.color = color
    self.position = position
    self.specularColor = specularColor
    self.type = type
  }

  public enum LightType: String, Decodable {
    case unused
    case Sun
    case Spot
    case Point
    case Ambient
  }
}

