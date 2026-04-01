//
//  SVCCommandRender.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//

import MetalKit
import lecs_swift
import VRTMath
import SVCDefinitions

enum SVCCommandRender {
  struct ChangeWorld: SVCDServiceCommand {
    let worldBasis: F3
    let worldUprightTransforms: [String: GEOTransform]
  }

  struct InitializePipelines: SVCDServiceCommand {
    let pixelFormat: MTLPixelFormat
  }

  struct Resize: SVCDServiceCommand {
    let screenDimensions: ScreenDimensions
  }

  struct Render: SVCDServiceCommand {
    let renderDescriptor: SVCRenderDescriptor
    let ecs: LECSWorld
  }
}
