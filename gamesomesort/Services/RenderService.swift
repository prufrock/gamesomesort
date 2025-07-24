//
//  RenderService.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit
import lecs_swift

class RenderService {
  private let config: AppCoreConfig
  private var renderer: RNDRRenderer?

  init(_ config: AppCoreConfig) {
    self.config = config
  }

  func sync(_ command: SVCCommandRender.Render) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer()

    activeRenderer.render(
      ecs: command.ecs,
      to: command.renderDescriptor,
    )
  }

  func sync(_ command: SVCCommandRender.Resize) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer()

    activeRenderer.resize(
      command.screenDimensions
    )
  }

  func sync(_ command: SVCCommandRender.InitializePipelines) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer()

    activeRenderer.initializePipelines(pixelFormat: command.pixelFormat)
    activeRenderer.initializeRenderPasses(
      pixelFormat: command.pixelFormat,
      depthStencilPixelFormat: config.services.renderService.depthStencilPixelFormat
    )
  }

  private func initRenderer() -> RNDRRenderer {
    let newRenderer: RNDRRenderer
    switch config.services.renderService.type {
    case .clearColor:
      newRenderer = RNDRClearColorRenderer(config: config)
    case .ersatz:
      newRenderer = RNDRErsatzRenderer()
    case .metal:
      newRenderer = RNDRErsatzRenderer()
    case .square:
      newRenderer = RNDRSquareRenderer(config: config)
    case .tileBased:
      newRenderer = RNDRTileBasedDeferredRenderer(config: config)
    }
    renderer = newRenderer
    return newRenderer
  }
}

enum RenderServiceType {
  case clearColor, ersatz, metal, square, tileBased
}
