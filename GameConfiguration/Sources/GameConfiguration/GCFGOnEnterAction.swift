//
//  GCFGOnEnterAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 7/3/26.
//

public enum GCFGOnEnterAction: Codable {
  case gotoLevel(levelId: String)
  case gotoExit(levelId: String, doorId: String)
  case healFull
  case pass
}
