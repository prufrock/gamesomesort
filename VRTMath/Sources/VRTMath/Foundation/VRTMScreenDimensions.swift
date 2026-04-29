//
//  VRTMScreenDimensions.swift
//  VRTMath
//
//  Created by David Kanenwisher on 4/28/26.
//

import Foundation

public struct VRTMScreenDimensions {
  // The ratio between the width and the height
  public let aspectRatio: Float

  // The size of the screen in pixels, useful in fragment shaders
  private let pixelWidth: Float
  private let pixelHeight: Float

  // The size of the screen in points
  public var pointWidth: Float {
    pixelWidth / scaleFactor
  }

  public var pointHeight: Float {
    pixelHeight / scaleFactor
  }

  public var cgSize: CGSize {
    CGSize(width: Double(pixelWidth), height: Double(pixelHeight))
  }
  // The platform dependent amount to adjust positions reported by touches and clicks to actual pixels.
  private var scaleFactor: Float

  public init(pixelSize: CGSize, scaleFactor: Float) {
    self.aspectRatio = pixelSize.aspectRatio().f
    pixelWidth = pixelSize.width.f
    pixelHeight = pixelSize.height.f
    self.scaleFactor = scaleFactor
  }

  public init() {
    self.aspectRatio = 1.0
    pixelWidth = 1.0
    pixelHeight = 1.0
    scaleFactor = 1.0
  }
}
