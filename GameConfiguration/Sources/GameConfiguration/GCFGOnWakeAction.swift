//
//  GCFGOnWakeAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 5/31/26.
//

public enum GCFGOnWakeAction: Codable {
  case creates(creatureId: String)
  case createsMoveBtns(up: Int, down: Int, left: Int, right: Int)
  case levelStart
  case queuesToPlayer
}
