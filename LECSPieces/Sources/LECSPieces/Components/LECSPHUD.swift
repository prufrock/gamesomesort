//
//  LECSPHUD.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 4/29/26.
//

import lecs_swift
import VRTMath

public enum LECSPHUD {}

public extension LECSPHUD {
  enum Button {}
}

public extension LECSPHUD.Button {
  struct OnTap: LECSComponent {
    public let list: Set<LECSPOnTap.Action>

    public init() {
      list = []
    }

    public init (_ list: Set<LECSPOnTap.Action>) {
      self.list = list
    }
  }
}
