//
//  RNDRRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit
import lecs_swift

protocol RNDRRenderer {
  func resize(_ dimensions: ScreenDimensions)
  func render(ecs: LECSWorld, to renderDescriptor: RenderDescriptor)
  // The pixel format has to be derived from the view, where it's main actor isolated, so just passing the pixelFormat
  // without the whole view avoid problems with that.
  func initializePipelines(pixelFormat: MTLPixelFormat)
}

extension RNDRRenderer {
  // Default no-op implementation, to make it easier to add a bunch of RNDRRenderers
  func initializePipelines(pixelFormat: MTLPixelFormat) {}
}
