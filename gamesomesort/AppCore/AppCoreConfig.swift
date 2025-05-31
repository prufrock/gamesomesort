//
//  AppCoreConfig.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

struct AppCoreConfig {
  let services: Services

  struct Services {
    let renderService: AppCoreConfig.Services.RenderService

    struct RenderService {
      let type: RenderServiceType
      let clearColor: (Double, Double, Double, Double)
    }
  }
}
