//
//  ScreenDimensions.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/13/25.
//

import Foundation

struct ScreenDimensions {
  // The ratio between the width and the height
  let aspectRatio: Float

  // The size of the screen in pixels, useful in fragment shaders
  let pixelWidth: Float
  let pixelHeight: Float

  // The size of the screen in points
  var pointWidth: Float {
    pixelWidth / scaleFactor
  }

  var pointHeight: Float {
    pixelHeight / scaleFactor
  }

  var cgSize: CGSize {
    CGSize(width: Double(pixelWidth), height: Double(pixelHeight))
  }
  // The platform dependent amount to adjust positions reported by touches and clicks to actual pixels.
  var scaleFactor: Float

  init(pixelSize: CGSize, scaleFactor: Float) {
    self.aspectRatio = pixelSize.aspectRatio().f
    pixelWidth = pixelSize.width.f
    pixelHeight = pixelSize.height.f
    self.scaleFactor = scaleFactor
  }

  init() {
    self.aspectRatio = 1.0
    pixelWidth = 1.0
    pixelHeight = 1.0
    scaleFactor = 1.0
  }
}
