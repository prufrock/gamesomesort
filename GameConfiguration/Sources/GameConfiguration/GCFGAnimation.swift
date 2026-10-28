//
//  GCFGAnimation.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 10/27/26.
//

import VRTMath

// Describes basic animations.
public struct GCFGAnimation: Decodable {
  public let motion: Motion

  public init(motion: Motion) {
    self.motion = motion
  }

  public enum Motion: Decodable {
    // Set a velocity for continual movement
    case linear(velocity: F3)
  }
}
