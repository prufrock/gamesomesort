//
//  GCFGAnimationOscillatorExt.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 10/28/26.
//

import GameConfiguration
import LECSPieces
import VRTMath

extension GCFGAnimation.Oscillator {
  func toLECSP(anchor: F3) -> LECSPAnimation.Oscillator {
    return LECSPAnimation.Oscillator(
      amplitude: self.amplitude,
      anchor: anchor,
      frequency: self.frequency,
      phase: self.phase,
      scale: self.scale
    )
  }
}
