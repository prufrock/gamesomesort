//
//  LECSPClock.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/15/26.
//

import lecs_swift

// Keeps track of time in the game.
public struct LECSPClock: LECSComponent {
  // The total number of ticks passed.
  public var ticks: UInt
  // microseconds per tick
  public var tickLengthUs: UInt64

  public init() {
    ticks = 0
    tickLengthUs = 0
  }

  public init(ticks: UInt, tickLengthUs: UInt64) {
    self.ticks = ticks
    self.tickLengthUs = tickLengthUs
  }

  public func tick() -> LECSPClock {
    return Self.init(ticks: ticks + 1, tickLengthUs: tickLengthUs)
  }
}
