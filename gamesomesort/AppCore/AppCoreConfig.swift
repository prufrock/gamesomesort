//
//  AppCoreConfig.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

struct AppCoreConfig {
  let platform: Platform

  let services: Services

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
