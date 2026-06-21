//
//  LECSPHUD.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/29/26.
//

import lecs_swift

public enum LECSPHUD {}

public extension LECSPHUD {
  enum Button {}
}

public extension LECSPHUD.Button {
  struct OnTap: LECSComponent {
    public let list: Set<String>

    public init() {
      list = []
    }

    public init (_ list: Set<String>) {
      self.list = list
    }
  }
}
