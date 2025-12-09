//
//  World.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import Foundation
import lecs_swift

class GMWorld02: GMWorld {
  private let config: AppCoreConfig
  public let ecs: LECSWorld
  private(set) var map: GMTileMap
  private let ecsStarter: GMEcsStarter
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)

  private var tapSquare: LECSEntityId? = nil

  // systems
  private var aspectRatioSystem: LECSSystemId? = nil
  private var tapSystem: LECSSystemId? = nil
  private var velocitySystem: LECSSystemId? = nil
  private var emitterSystem: LECSSystemId? = nil

  init(config: AppCoreConfig, ecs: LECSWorld, map: GMTileMap, ecsStarter: GMEcsStarter) {
    self.config = config
    self.ecs = ecs
    self.map = map
    self.ecsStarter = ecsStarter

    self.start()
  }

  private func start() {
    print("start world 02")
    self.ecsStarter.start(ecs: self.ecs)

    let tapSquare = ecs.createEntity("tapSquare")
    ecs.addComponent(tapSquare, CTRadius(0.1))
    ecs.addComponent(tapSquare, CTColor(.red))
    self.tapSquare = tapSquare

    aspectRatioSystem = ecs.addSystem("aspectRatio", selector: [CTAspect.self]) { components, columns in
      return [CTAspect(aspect: self.screenDimensions.aspectRatio)]
    }

    tapSystem = ecs.addSystemWorldScoped(
      "collides",
      selector: [
        LECSId.self,
        LECSPosition2d.self,
        CTTagTap.self,
      ]
    ) { world, row, columns in
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

          // quick work around to clear balloons that are off the screen...
          if otherPosition.y < -5.0 {
            world.deleteEntity(otherEntityId.id)
          }

          if let selectedEntityId {
            world.deleteEntity(selectedEntityId.id)
          }
          selectedEntityId = nil
        }
      }

      return [tapEntityId, tapPosition, CTTagTap(), CTTagBalloon(), CTTagVisible()]
    }

    emitterSystem = ecs.addSystemWorldScoped(
      "emitterSystem",
      selector: [LECSPosition2d.self, CTBalloonEmitter.self],
    ) { world, row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      var emitter = row.component(at: 1, columns, CTBalloonEmitter.self)

      // TODO: get the delta from outer update loop
      emitter.update(0.01)
      if emitter.emit() {
        let balloon = world.createEntity(UUID.init().uuidString)
        world.addComponent(balloon, position)
        world.addComponent(balloon, CTRadius(1.0))
        world.addComponent(balloon, CTColor(.yellow))
        world.addComponent(balloon, CTTagVisible())
        world.addComponent(balloon, CTTagBalloon())
        world.addComponent(balloon, LECSVelocity2d(x: 0.0, y: -1 * (emitter.rate * 0.0004)))
      }
      return [position, emitter]
    }

    velocitySystem = ecs.addSystemWorldScoped(
      "velocity",
      selector: [
        LECSId.self,
        LECSPosition2d.self,
        LECSVelocity2d.self,
      ],
    ) { world, row, columns in
      let entityId = row.component(at: 0, columns, LECSId.self)
      let position = row.component(at: 1, columns, LECSPosition2d.self)
      let velocity = row.component(at: 2, columns, LECSVelocity2d.self)

      let newPosition = position.position + velocity.velocity

      return [entityId, LECSPosition2d(newPosition), velocity]
    }
  }
  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move it forward.
  func update(timeStep: Float, input: GMGameInput) -> any CTSQueue<GMWorldCommands> {
    let playerCamera = ecs.gmCameraFirstPerson("playerCamera")!
    var gameCommands: any CTSQueue<GMWorldCommands> = CTSQueueArray<GMWorldCommands>()

    var inputEvents: any CTSQueue<GMGameInput.Events> = input.events
    while !inputEvents.isEmpty {
      let event: GMGameInput.Events = inputEvents.dequeue()!
      switch event {
      case .tap(tapLocation: let loc, lastTapTime: _):
        let tapLocation = INTapLocation(location: loc)

        let worldLocation = tapLocation.screenToWorldOnZPlane(
          screenDimensions: screenDimensions,
          targetZPlaneWorldCoord: 1,
          camera: playerCamera
        )!

        ecs.addComponent(tapSquare!, LECSPosition2d(x: worldLocation.x, y: worldLocation.y))
        ecs.addComponent(tapSquare!, CTTagTap())
        ecs.addComponent(tapSquare!, CTTagVisible())
        if let tapSystem = self.tapSystem {
          ecs.processSystemWorldScoped(system: tapSystem)
        }
        ecs.removeComponent(tapSquare!, component: CTTagTap.self)
        gameCommands.enqueue(.start(level: 1))
      case .screenSizeChanged:
        break
      }
    }

    if let velocitySystem {
      ecs.processSystemWorldScoped(system: velocitySystem)
    }

    if let emitterSystem {
      ecs.processSystemWorldScoped(system: emitterSystem)
    }
    //print("world updated: \(timeStep)")
    return gameCommands
  }

  func update(_ dimensions: ScreenDimensions) {
    screenDimensions = dimensions

    if let aspectRatioSystem = self.aspectRatioSystem {
      ecs.process(system: aspectRatioSystem)
    }
  }
}
