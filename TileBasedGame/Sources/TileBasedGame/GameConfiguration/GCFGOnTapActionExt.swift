//
//  GCFGTapAction.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 10/25/26.
//

import GameConfiguration
import LECSPieces

extension Array where Element == GCFGOnTapAction {
  func toSetOfLECSPOnTapAction() -> Set<LECSPOnTap.Action> {
    return Set(self.map { item in
      switch item {
      case .affectTargetStat(stat: let stat, value: let value):
        return LECSPOnTap.Action.affectTargetStat(value: value)
      case .exit:
        return LECSPOnTap.Action.exit
      case .move:
        return LECSPOnTap.Action.move
      case .moveConstant(velocity: let velocity):
        return LECSPOnTap.Action.moveConstant(velocity: velocity)
      case .reload:
        return LECSPOnTap.Action.reload
      }
    })
  }
}
