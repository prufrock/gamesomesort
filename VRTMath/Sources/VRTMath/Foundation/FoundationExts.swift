//
//  FoundationExts.swift
//  VRTMath
//
//  Created by David Kanenwisher on 4/28/26.
//

import Foundation

extension CGFloat {
  var f: Float {
    Float(self)
  }
}

extension CGSize {
  func aspectRatio() -> CGFloat {
    return width / height
  }
}
