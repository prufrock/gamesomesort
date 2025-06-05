//
//  RenderService.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit

@MainActor
class RenderService {
  private let config: AppCoreConfig
  private var renderer: RNDRRenderer?

  init(_ config: AppCoreConfig) {
    self.config = config
  }

  func sync(_ command: RenderCommand) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer(view: command.metalView)

    activeRenderer.render(
      to: command.metalView,
    )
  }

  private func initRenderer(view: MTKView) -> RNDRRenderer {
    let newRenderer: RNDRRenderer
    switch config.services.renderService.type {
    case .clearColor:
      newRenderer = RNDRClearColorRenderer(metalView: view)
    case .ersatz:
      newRenderer = RNDRErsatzRenderer()
    case .metal:
      newRenderer = RNDRErsatzRenderer()
    case .square:
      newRenderer = RNDRSquareRenderer(config: config)
    }
    renderer = newRenderer
    return newRenderer
  }
}

struct RenderCommand: ServiceCommand {
  let metalView: MTKView

  init(
    metalView: MTKView,
  ) {
    self.metalView = metalView
  }
}

enum RenderServiceType {
  case clearColor, ersatz, metal, square
}
