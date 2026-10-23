//
//  LECSPClock.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/15/26.
//

import lecs_swift

/// Keeps track of time in the game.
struct LECSPClock: LECSComponent {
  /// The amount of time elapsed since the start of the last frame.
  var elapsedTime: Float = 0


  var totalElapsedTime: Float = 0
}
