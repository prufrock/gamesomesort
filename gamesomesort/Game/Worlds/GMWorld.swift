//
//  World.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import Foundation
import lecs_swift

class GMWorld {
  private let config: AppCoreConfig
  public let ecs: LECSWorld
  private(set) var map: GMTileMap
  private let ecsStarter: GMEcsStarter
  private var aspectRatioSystem: LECSSystemId? = nil
  private var aspect: Float = 1.0
  private var size: CGSize = .zero
  private var screenSize: CGSize = .zero

  init(config: AppCoreConfig, ecs: LECSWorld, map: GMTileMap, ecsStarter: GMEcsStarter) {
    self.config = config
    self.ecs = ecs
    self.map = map
    self.ecsStarter = ecsStarter

    self.start()
  }

  private func start() {
    self.ecsStarter.start(ecs: self.ecs)
    aspectRatioSystem = ecs.addSystem("aspectRatio", selector: [CTAspect.self]) { components, columns in
      return [CTAspect(aspect: self.aspect)]
    }
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move it forward.
  func update(timeStep: Float, input: GMGameInput) {
    var inputEvents: any CTSQueue<GMGameInput.Events> = input.events
    while !inputEvents.isEmpty {
      let event: GMGameInput.Events = inputEvents.dequeue()!
      switch event {
      case .tap(tapLocation: let loc, lastTapTime: _):
        let tapLocation = INTapLocation(location: loc)
        let ndcLocation = tapLocation.screenToNdc(screenWidth: screenSize.width.f, screenHeight: screenSize.height.f)
        print("W:ndc: \(ndcLocation)")
      case .screenSizeChanged(size: let newSize):
        print("W:screen size changed\(newSize)")
        screenSize = newSize
      }
    }

    //print("world updated: \(timeStep)")
  }

  func update(size: CGSize) {
    aspect = size.aspectRatio().f
    self.size = size
    if let aspectRatioSystem = self.aspectRatioSystem {
      ecs.process(system: aspectRatioSystem)
    }
  }
}
