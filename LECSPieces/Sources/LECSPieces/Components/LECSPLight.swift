//
//  LECSPLight.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/20/26.
//

import lecs_swift
import VRTMath

public struct LECSPLight: LECSComponent {
  public var type: LightType
  public var specularColor: Float3
  public var attenuation: Float3
  public var coneAngle: Float
  public var coneDirection: Float3
  public var coneAttenuation: Float

  public init() {
    type = .Point
    specularColor = [1, 1, 1]
    attenuation = .zero
    coneAngle = 0
    coneDirection = .zero
    coneAttenuation = 0
  }

  // TODO: how to bridge these with a shader?
  public enum LightType: Int {
    case unused = 0
    case Sun = 1
    case Spot = 2
    case Point = 3
    case Ambient = 4
  }
}
