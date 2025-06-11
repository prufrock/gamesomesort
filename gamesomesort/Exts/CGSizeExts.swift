//
//  CGSizeExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/11/25.
//

import Foundation

extension CGSize {
  func aspectRatio() -> CGFloat {
    return width / height
  }
}
