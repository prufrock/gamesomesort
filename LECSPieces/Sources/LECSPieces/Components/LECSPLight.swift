//
//  LECSPLight.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/20/26.
//

import lecs_swift
import VRTMath

struct LECSPLight: LECSComponent {
  var type: LightType
  var specularColor: Float3
  var attenuation: Float3
  var coneAngle: Float
  var coneDirection: Float3
  var coneAttenuation: Float

  init() {
    type = .Point
    specularColor = [1, 1, 1]
    attenuation = .zero
    coneAngle = 0
    coneDirection = .zero
    coneAttenuation = 0
  }

  // TODO: how to bridge these with a shader?
  enum LightType: Int {
    case unused = 0
    case Sun = 1
    case Spot = 2
    case Point = 3
    case Ambient = 4
  }
}
