//
//  SVCCommandRender.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//

import MetalKit
import lecs_swift

enum SVCCommandRender {
  struct ChangeWorld: ServiceCommand {
    let worldBasis: F3
    let worldUprightTransforms: [String:GEOTransform]
  }

  struct InitializePipelines: ServiceCommand {
    let pixelFormat: MTLPixelFormat
  }

  struct Resize: ServiceCommand {
    let screenDimensions: ScreenDimensions
  }

  struct Render: ServiceCommand {
    let renderDescriptor: SVCRenderDescriptor
    let ecs: LECSWorld
  }
}
