//
//  RenderService.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit

class RenderService {
  private let config: AppCoreConfig
  private var renderer: RNDRRenderer?

  init(_ config: AppCoreConfig) {
    self.config = config
  }

  func sync(_ command: RenderCommand) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer()

    activeRenderer.render(
      to: command.renderDescriptor,
    )
  }

  func sync(_ command: ResizeCommand) {
    let activeRenderer: RNDRRenderer = renderer ?? initRenderer()

    activeRenderer.resize(
      size: command.size
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
    }
    renderer = newRenderer
    return newRenderer
  }
}

struct RenderCommand: ServiceCommand {
  let renderDescriptor: RenderDescriptor
}

struct ResizeCommand: ServiceCommand {
  let size: CGSize
}

enum RenderServiceType {
  case clearColor, ersatz, metal, square
}

struct RenderDescriptor {
  let view: MTKView
  let currentRenderPassDescriptor: MTLRenderPassDescriptor
  let currentDrawable: MTLDrawable
}
