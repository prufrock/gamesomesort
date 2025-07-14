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
  private var aspect: Float = 1.0
  private var size: CGSize = .zero
  private var screenSize: CGSize = .zero

  private var tapSquare: LECSEntityId? = nil

  // systems
  private var aspectRatioSystem: LECSSystemId? = nil
  private var tapSystem: LECSSystemId? = nil

  init(config: AppCoreConfig, ecs: LECSWorld, map: GMTileMap, ecsStarter: GMEcsStarter) {
    self.config = config
    self.ecs = ecs
    self.map = map
    self.ecsStarter = ecsStarter

    self.start()
  }

  private func start() {
    print("start")
    self.ecsStarter.start(ecs: self.ecs)

    let tapSquare = ecs.createEntity("tapSquare")
    ecs.addComponent(tapSquare, CTRadius(0.1))
    ecs.addComponent(tapSquare, CTColor(.red))
    self.tapSquare = tapSquare

    aspectRatioSystem = ecs.addSystem("aspectRatio", selector: [CTAspect.self]) { components, columns in
      return [CTAspect(aspect: self.aspect)]
    }

    tapSystem = ecs.addSystemWorldScoped(
      "collides",
      selector: [
        LECSId.self,
        LECSPosition2d.self,
        CTTagTap.self,
      ]
    ) {
      world,
      row,
      columns in
      let tapEntityId = row.component(at: 0, columns, LECSId.self)
      let tapPosition = row.component(at: 1, columns, LECSPosition2d.self)

      var selectedEntityId: LECSId? = nil
      world.select(
        [LECSId.self, CTColor.self, LECSPosition2d.self, CTRadius.self, CTTagBalloon.self, CTTagVisible.self]
      ) { otherRow, otherColumns in
        let otherEntityId = otherRow.component(at: 0, otherColumns, LECSId.self)
        let otherPosition = otherRow.component(at: 2, otherColumns, LECSPosition2d.self)
        let otherRadius = otherRow.component(at: 3, otherColumns, CTRadius.self)
        let otherRectangle = GEORectangle(position: otherPosition.position, radius: otherRadius.radius)

        if otherEntityId != tapEntityId {

          if otherRectangle.contains(tapPosition.position) {
            selectedEntityId = otherEntityId
          }

          if let selectedEntityId {
            world.removeComponent(selectedEntityId.id, component: CTTagVisible.self)
          }
          selectedEntityId = nil
        }
      }

      return [tapEntityId, tapPosition, CTTagTap(), CTTagBalloon(), CTTagVisible()]
    }
  }

  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move it forward.
  func update(timeStep: Float, input: GMGameInput) {
    let playerCamera = ecs.gmCameraFirstPerson("playerCamera")!

    var inputEvents: any CTSQueue<GMGameInput.Events> = input.events
    while !inputEvents.isEmpty {
      let event: GMGameInput.Events = inputEvents.dequeue()!
      switch event {
      case .tap(tapLocation: let loc, lastTapTime: _):
        let tapLocation = INTapLocation(location: loc)

        let worldLocation = tapLocation.screenToWorldOnZPlane(
          viewportSize: screenSize,
          targetZPlaneWorldCoord: 1,
          camera: playerCamera
        )!

        ecs.addComponent(tapSquare!, LECSPosition2d(x: worldLocation.x, y: worldLocation.y))
        ecs.addComponent(tapSquare!, CTTagTap())
        if let tapSystem = self.tapSystem {
          ecs.processSystemWorldScoped(system: tapSystem)
        }
        ecs.removeComponent(tapSquare!, component: CTTagTap.self)
      case .screenSizeChanged(size: let newSize):
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
