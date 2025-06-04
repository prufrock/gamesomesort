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
      services: AppCoreConfig.Services(
        renderService: AppCoreConfig.Services.RenderService(
          type: .clearColor,
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
