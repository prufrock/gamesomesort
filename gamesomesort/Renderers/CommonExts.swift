//
//  CommonExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

// These extensions make it so you can write Position.index rather than Int(Position.rawValue)

extension RNDRBufferIndices {
  var index: Int {
    Int(self.rawValue)
  }
}

extension RNDRAttributes {
  var index: Int {
    return Int(self.rawValue)
  }
}
