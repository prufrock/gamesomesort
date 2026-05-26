//
//  TBDGame.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import DataStructures
import Foundation
import VRTMath

public extension TBDGame {
  struct Input {
    public let events: any DSQueue<Events>
    public let screenDimensions: VRTMScreenDimensions

    public enum Events {
      case tap(tapLocation: F2, lastTapTime: Double)
      case screenSizeChanged(size: CGSize)
    }

    public init() {
      events = DSQueueArray<Events>()
      screenDimensions = .init()
    }

    public init(events: any DSQueue<Events>) {
      self.events = events
      screenDimensions = .init()
    }

    public init(
      events: any DSQueue<Events>,
      screenDimensions: VRTMScreenDimensions
    ) {
      self.events = events
      self.screenDimensions = screenDimensions
    }
  }
}
