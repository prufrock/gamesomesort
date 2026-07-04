//
//  GCFGOnEnterAction.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 7/3/26.
//

public enum GCFGOnEnterAction: Codable {
  case gotoLevel(levelId: String)
  case pass
}
