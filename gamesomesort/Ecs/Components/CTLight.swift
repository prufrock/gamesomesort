//
//  CTLight.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/5/25.
//

import lecs_swift
import VRTMath

struct CTLight: LECSComponent {
  var type: LightType
  var specularColor: Float3
  var attenuation: Float3
  var coneAngle: Float
  var coneDirection: Float3
  var coneAttenuation: Float

  init() {
    type = Point
    specularColor = [1, 1, 1]
    attenuation = .zero
    coneAngle = 0
    coneDirection = .zero
    coneAttenuation = 0
  }
}
