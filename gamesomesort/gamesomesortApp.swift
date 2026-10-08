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
            modelConfig: [
              // Don't use instanced rendering for now, to keep non-instanced rendering tested
              .init(name: "box-golem.usdz", renderInstanced: false),
              .init(name: "brick-sphere.usdz", renderInstanced: true),
              .init(name: "ref-tile.usdz", renderInstanced: true),
              .init(name: "square-bella.usdz", renderInstanced: true),
              .init(name: "tile-tree-three.usdz", renderInstanced: true),
            ]
          ),
          fileService: AppCoreConfig.Services.FileService(
            levelsFile: AppCoreConfig.Services.FileService.FileDescriptor(
              name: "levels",
              ext: .json
            ),
            worldFiles: [
              "world001": AppCoreConfig.Services.FileService.FileDescriptor(
                name: "world001",
                ext: .json
              )
            ],
          )
        ),
        game: AppCoreConfig.Game(
          world: AppCoreConfig.Game.World(
            initialLevel: 0,
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
