//
//  GCFGOnWakeAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 5/31/26.
//

import VRTMath

public enum GCFGOnTapAction: Decodable {
  case reload
  case affectTargetStat(stat: GCFGCreature.Stats, value: Int)
  case moveConstant(velocity: F3)
  case move
  case exit
  case wait
}
