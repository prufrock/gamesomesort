//
//  GCFGOnWakeAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 5/31/26.
//

public enum GCFGOnWakeAction: Codable {
  case creates(creatureId: String)
  case queuesToPlayer
}
