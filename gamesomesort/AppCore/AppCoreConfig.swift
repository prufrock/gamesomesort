//
//  AppCoreConfig.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import MetalKit

struct AppCoreConfig {
  let platform: Platform

  let services: Services

  let game: Game

  struct Game {

    let tapDelay: Int = 50
    let world: World
    let timeLimit: Float = Float.infinity
    let upVector: F3 = [0, -1, 0]

    struct World {
      let ecsArchetypeSize: Int
    }
  }

  // Configuring how the platform interacts with the Game
  struct Platform {
    let maximumTimeStep: Float  // the maximum length of a time step
    let worldTimeStep: Float  // number of steps to take each frame
    let scaleFactor: Float  // Used to convert points to pixels, depends on the platform
  }

  struct Services {
    let renderService: AppCoreConfig.Services.RenderService
    let fileService: AppCoreConfig.Services.FileService

    struct RenderService {
      let type: RenderServiceType
      let clearColor: (Double, Double, Double, Double)
      let depthStencilPixelFormat: MTLPixelFormat = .depth32Float  // The pixel format for the MTLViews depth stencil.
      let models: [String]
      let tbdrRender: RNDRTBDRRenderType
    }

    struct FileService {
      let levelsFile: FileDescriptor

      struct FileDescriptor {
        let name: String
        let ext: FileType
      }

      enum FileType: String, CaseIterable {
        case json = "json"
      }
    }
  }
}

extension AppCoreConfig {
  static let testDefault: AppCoreConfig = .init(
    platform: AppCoreConfig.Platform(
      maximumTimeStep: 1 / 20,  // don't step bigger than this (minimum of 20 fps)
      worldTimeStep: 1 / 120,  // 120 steps a second
      scaleFactor: 1.0
    ),
    services: AppCoreConfig.Services(
      renderService: AppCoreConfig.Services.RenderService(
        type: .ersatz,
        clearColor: (0.3, 0.0, 0.3, 1.0),
        models: [],
        tbdrRender: .forward
      ),
      fileService: AppCoreConfig.Services.FileService(
        levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(name: "levels", ext: .json),
      )
    ),
    game: AppCoreConfig.Game(
      world: AppCoreConfig.Game.World(ecsArchetypeSize: 500)
    )
  )
}
