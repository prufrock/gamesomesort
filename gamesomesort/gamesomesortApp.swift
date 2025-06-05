//
//  gamesomesortApp.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/29/25.
//

import SwiftUI

@main
struct gamesomesortApp: App {
  private let appCore = AppCore(
    AppCoreConfig(
      platform: AppCoreConfig.Platform(
        maximumTimeStep: 1 / 20,  // don't step bigger than this (minimum of 20 fps)
        worldTimeStep: 1 / 120  // 120 steps a second
      ),
      services: AppCoreConfig.Services(
        renderService: AppCoreConfig.Services.RenderService(
          type: .square,
          clearColor: (0.3, 0.0, 0.3, 1.0)
        ),
        fileService: AppCoreConfig.Services.FileService(
          levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(name: "levels", ext: .json),
        )
      )
    )
  )
  var body: some Scene {
    WindowGroup {
      ContentView(appCore: appCore)
    }
  }
}
