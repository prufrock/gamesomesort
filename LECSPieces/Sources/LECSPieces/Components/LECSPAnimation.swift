//
//  LECSPAnimation.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/27/26.
//

import lecs_swift
import VRTMath

public struct LECSPAnimation: LECSComponent {
  public let motion: Motion

  public init() {
    motion = .linear(velocity: [0, 0, 0])
  }

  public init(motion: Motion) {
    self.motion = motion
  }

  public enum Motion {
    case linear(velocity: F3)
    case sine(oscillator: Oscillator)
  }

  public struct Oscillator: Decodable {
    public var amplitude: F3
    public var anchor: F3
    public var frequency: Float
    public var phase: Float
    public var scale: Bool

    public init(amplitude: F3, anchor: F3, frequency: Float, phase: Float, scale: Bool) {
      self.amplitude = amplitude
      self.anchor = anchor
      self.frequency = frequency
      self.phase = phase
      self.scale = scale
    }
  }
}
