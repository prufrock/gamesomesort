//
//  LECPSTagGroupA.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 7/3/26.
//

import lecs_swift

// This might be goofy, but I am going to try it as way to query
// without having to loop again.
extension LECSPTag {
  public struct GroupA: LECSComponent {
    public let exists = true

    public init() {}
  }
}
