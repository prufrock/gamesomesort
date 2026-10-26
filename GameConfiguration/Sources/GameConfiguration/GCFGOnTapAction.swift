//
//  GCFGOnWakeAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 5/31/26.
//

import VRTMath

public enum GCFGOnTapAction: Codable {
  case reload
  case moveConstant(velocity: F3)
  case move
  case exit
}
