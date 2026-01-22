//
//  CTEvent.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 1/21/26.
//

import lecs_swift

struct CTEvent: LECSComponent {
  var nextEventId: LECSId?
  var srcEntity: LECSId
  var type: CTEventType

  init() {
    nextEventId = nil
    srcEntity = LECSId(0)
    type = .none
  }

  init(
    nextEventId: LECSId?,
    srcEntity: LECSId,
    type: CTEventType
  ) {
    self.nextEventId = nextEventId
    self.srcEntity = srcEntity
    self.type = type
  }
}

enum CTEventType {
  case none
  case tap
}
