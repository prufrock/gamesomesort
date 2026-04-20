//
//  TBDGGameExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 4/19/26.
//

import TileBasedGame
import lecs_swift
import VRTMath
import DataStructures

extension TBDGWorld: GMWorld {
  var ecs: any LECSWorld {
    LECSCreateWorld(archetypeSize: 50)
  }

  var basis: F3 {
    F3(0, 0, 0)
  }

  var uprightTransforms: [String: GEOTransform] {
    [:]
  }

  func update(timeStep: Float, input: GMGameInput) -> any DSQueue<GMWorldCommands> {
    DSQueueArray<GMWorldCommands>()
  }

  func update(_ dimensions: ScreenDimensions) {
  }
}
