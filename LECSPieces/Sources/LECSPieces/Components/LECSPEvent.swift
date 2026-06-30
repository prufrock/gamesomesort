//
//  LECSPEvent.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 5/11/26.
//

import lecs_swift

public struct LECSPEvent: LECSComponent {
  public var event: EventType

  public init() {
    event = .none
  }

  public init(event: EventType) {
    self.event = event
  }
}

public extension LECSPEvent {
  enum EventType: Equatable {
    case awake(LECSId)
    case levelStarted
    case playerTurnEnded
    case playerTurnStarted
    case none
    case touched(LECSId)
  }
}
