//
//  LECSExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/17/25.
//

import lecs_swift

extension LECSWorld {
  func entity(_ name: String) -> LECSEntityId? {
    entity(named: LECSName(name))
  }
}
