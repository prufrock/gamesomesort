//
//  SVCCommandRender.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//

import MetalKit
import lecs_swift

enum SVCCommandRender {
  struct InitializePipelines: ServiceCommand {
    let pixelFormat: MTLPixelFormat
  }

  struct Resize: ServiceCommand {
    let screenDimensions: ScreenDimensions
  }

  struct Render: ServiceCommand {
    let renderDescriptor: RenderDescriptor
    let ecs: LECSWorld
  }
}
