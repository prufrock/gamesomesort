//
//  gamesomesortApp.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/29/25.
//

import SwiftUI

@main
struct gamesomesortApp: App {
  #if os(macOS)
  private let scaleFactor = Float(NSScreen.main?.backingScaleFactor ?? 1)
  #elseif os(iOS)
  private let scaleFactor = Float(UIScreen.main.scale)
  #endif
  private let appCore: AppCore

  init() {
    self.appCore = AppCore(
      AppCoreConfig(
        platform: AppCoreConfig.Platform(
          maximumTimeStep: 1 / 20,  // don't step bigger than this (minimum of 20 fps)
          worldTimeStep: 1 / 120,  // 120 steps a second
          scaleFactor: scaleFactor
        ),
        services: AppCoreConfig.Services(
          renderService: AppCoreConfig.Services.RenderService(
            type: .tileBased,
            clearColor: (0.3, 0.0, 0.3, 1.0),
            models: ["brick-sphere.usdz"],
            tbdrRender: .tbdr
          ),
          fileService: AppCoreConfig.Services.FileService(
            levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(name: "levels", ext: .json),
          )
        ),
        game: AppCoreConfig.Game(
          world: AppCoreConfig.Game.World(
            ecsArchetypeSize: 500,
          )
        )
      )
    )
  }
  var body: some Scene {
    WindowGroup {
      ContentView(appCore: appCore)
    }
  }
}
