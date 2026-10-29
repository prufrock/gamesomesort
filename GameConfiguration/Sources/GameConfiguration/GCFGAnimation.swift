//
//  GCFGAnimation.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 10/27/26.
//

import VRTMath

// Describes basic animations.
public enum GCFGAnimation: Decodable {
  // Set a velocity for continual movement
  case linear(velocity: F3)
  // A sinusoidal animation
  // Start with just velicity and unconfigurable wave
  case sine(oscillator: Oscillator)

  public struct Oscillator: Decodable {
    public var frequency: Float
    public var amplitude: F3
    public var phase: Float
    public var scale: Bool
  }
}
