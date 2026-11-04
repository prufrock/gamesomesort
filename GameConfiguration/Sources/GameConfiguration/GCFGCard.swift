//
//  GCFGCard.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 11/1/26.
//

import VRTMath

public struct GCFGCard: Decodable {
  public let hitPoints: Int
  public let movement: [F3]?
}
