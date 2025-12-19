//
//  RNDRErsatzRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit
import lecs_swift

/// Does nothing, useful for testing in iCloud which doesn't support Metal.
class RNDRErsatzRenderer: RNDRRenderer {
  public func render(ecs: LECSWorld, to renderDescriptor: SVCRenderDescriptor) {
    //no-op
  }

  public func resize(_ dimensions: ScreenDimensions) {
    // no-op
  }

  func worldChanged(
    worldBasis: F3,
    worldUprightTransforms: [String: GEOTransform]
  ) {
    // no-op
  }
}
