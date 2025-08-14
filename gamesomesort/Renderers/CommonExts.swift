//
//  CommonExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/6/25.
//

// These extensions make it so you can write Position.index rather than Int(Position.rawValue)

extension SHDRBufferIndices {
  var index: Int {
    Int(self.rawValue)
  }
}

extension SHDRAttributes {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension SHDRTextureIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension SHDRRenderTargetIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}
