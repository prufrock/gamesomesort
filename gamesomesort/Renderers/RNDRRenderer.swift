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
  func resize(_ dmensions: ScreenDimensions)
  func render(ecs: LECSWorld, to renderDescriptor: SVCRenderDescriptor)
  // The pixel format has to be derived from the view, where it's main actor isolated, so just passing the pixelFormat
  // without the whole view avoid problems with that.
  func initializePipelines(pixelFormat: MTLPixelFormat)

  func initializeRenderPasses(pixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat)

  /// Called when the world changes, right now so the models can change their upright
  /// transform as needed.
  func worldChanged(worldBasis: F3, worldUprightTransforms: [String:GEOTransform])
}

extension RNDRRenderer {
  // Default no-op implementation, to make it easier to add a bunch of RNDRRenderers
  func initializePipelines(pixelFormat: MTLPixelFormat) {}
  func initializeRenderPasses(pixelFormat: MTLPixelFormat, depthStencilPixelFormat: MTLPixelFormat) {}
}
