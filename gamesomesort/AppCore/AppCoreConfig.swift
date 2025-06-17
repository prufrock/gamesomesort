//
//  AppCoreConfig.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

struct AppCoreConfig {
  let platform: Platform

  let services: Services

  let game: Game

  struct Game {

    let world: World

    struct World {
      let ecsArchetypeSize: Int
    }
  }

  // Configuring how the platform interacts with the Game
  struct Platform {
    let maximumTimeStep: Float  // the maximum length of a time step
    let worldTimeStep: Float  // number of steps to take each frame
  }

  struct Services {
    let renderService: AppCoreConfig.Services.RenderService
    let fileService: AppCoreConfig.Services.FileService

    struct RenderService {
      let type: RenderServiceType
      let clearColor: (Double, Double, Double, Double)
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
      worldTimeStep: 1 / 120  // 120 steps a second
    ),
    services: AppCoreConfig.Services(
      renderService: AppCoreConfig.Services.RenderService(
        type: .ersatz,
        clearColor: (0.3, 0.0, 0.3, 1.0)
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
