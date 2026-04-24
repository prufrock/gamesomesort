//
//  World.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import DataStructures
import Foundation
import lecs_swift
import VRTMath
import LECSPieces

private typealias Rect = VRTM2D.Rectangle

class GMWorld01: GMWorld {
  private let config: AppCoreConfig
  public let ecs: LECSWorld
  private(set) var map: GMTileMap
  private let ecsStarter: GMEcsStarter
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  public var basis: F3 {
    config.game.world.world01.worldBasis
  }
  public var uprightTransforms: [String: GEOTransform] {
    config.game.world.world00.uprightTransforms
  }

  private var tapSquare: LECSEntityId? = nil

  // systems
  private var aspectRatioSystem: LECSSystemId? = nil
  private var tapSystem: LECSSystemId? = nil
  private var collisionSystem: LECSSystemId? = nil
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
    print("start world 01")
    self.ecsStarter.start(ecs: self.ecs)

    let tapSquare = ecs.createEntity("tapSquare")
    ecs.addComponent(tapSquare, LECSPRadius(0.1))
    ecs.addComponent(tapSquare, LECSPColor(.red))
    ecs.addComponent(tapSquare, LECSPTagVisible())
    ecs.addComponent(tapSquare, LECSPModel("button-one"))
    ecs.addComponent(tapSquare, LECSPQuaternion(Float4x4.identity.q))
    ecs.addComponent(tapSquare, LECSPScale3d(F3(repeating: 0.1)))
    self.tapSquare = tapSquare

    aspectRatioSystem = ecs.addSystem("aspectRatio", selector: [LECSPAspect.self]) { components, columns in
      return [LECSPAspect(aspect: self.screenDimensions.aspectRatio)]
    }

    collisionSystem = ecs.addSystemWorldScoped(
      "collides",
      selector: [
        LECSId.self,
        LECSPPosition3d.self,
        CTTagTap.self,
      ]
    ) { world, row, columns in
      let tapEntityId = row.component(at: 0, columns, LECSId.self)
      let tapPosition = row.component(at: 1, columns, LECSPPosition3d.self)

      var selectedEntityId: LECSId? = nil
      world.select(
        [LECSId.self, LECSPColor.self, LECSPPosition3d.self, LECSPRadius.self, CTTagBalloon.self, LECSPTagVisible.self]
      ) { otherRow, otherColumns in
        let otherEntityId = otherRow.component(at: 0, otherColumns, LECSId.self)
        let otherPosition = otherRow.component(at: 2, otherColumns, LECSPPosition3d.self)
        let otherRadius = otherRow.component(at: 3, otherColumns, LECSPRadius.self)
        let otherRectangle = Rect(position: otherPosition.position.xy, radius: otherRadius.radius)

        if otherEntityId != tapEntityId {

          if otherRectangle.contains(tapPosition.position.xy) {
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

      return [tapEntityId, tapPosition, CTTagTap(), CTTagBalloon(), LECSPTagVisible()]
    }

    tapSystem = ecs.addSystemWorldScoped(
      "tapSystem",
      selector: [
        LECSId.self,
        LECSPPosition3d.self,
        CTTagTap.self,
      ]
    ) { world, row, columns in
      let tapEntityId = row.component(at: 0, columns, LECSId.self)
      let tapPosition = row.component(at: 1, columns, LECSPPosition3d.self)

      world.select(
        [LECSId.self, LECSPPosition3d.self, LECSPRadius.self, CTTappable.self]
      ) { otherRow, otherColumns in
        let otherEntityId = otherRow.component(at: 0, otherColumns, LECSId.self)
        let otherPosition = otherRow.component(at: 1, otherColumns, LECSPPosition3d.self)
        let otherRadius = otherRow.component(at: 2, otherColumns, LECSPRadius.self)
        let otherRectangle = Rect(
          position: otherPosition.position.xy,
          radius: otherRadius.radius
        )

        if otherEntityId != tapEntityId {

          if otherRectangle.contains(Float2(tapPosition.x, tapPosition.y)) {
            world.addComponent(otherEntityId.id, CTTappable(tapped: true))
          }
        }
      }

      return [tapEntityId, tapPosition, CTTagTap()]
    }

    emitterSystem = ecs.addSystemWorldScoped(
      "emitterSystem",
      selector: [LECSPPosition3d.self, CTBalloonEmitter.self],
    ) { world, row, columns in
      let position = row.component(at: 0, columns, LECSPPosition3d.self)
      var emitter = row.component(at: 1, columns, CTBalloonEmitter.self)

      // TODO: get the delta from outer update loop
      emitter.update(0.01)
      if emitter.emit() {
        let balloon = world.createEntity(UUID.init().uuidString)
        world.addComponent(balloon, position)
        world.addComponent(balloon, LECSPModel("brick-sphere.usdz"))
        world.addComponent(balloon, LECSPRadius(1.0))
        world.addComponent(balloon, LECSPColor(.yellow))
        world.addComponent(balloon, LECSPQuaternion())
        world.addComponent(balloon, LECSPScale3d())
        world.addComponent(balloon, LECSPTagVisible())
        world.addComponent(balloon, CTTagBalloon())
        world.addComponent(
          balloon,
          LECSVelocity2d(x: 0.0, y: -1 * (emitter.rate * 0.0004))
        )
      }
      return [position, emitter]
    }

    velocitySystem = ecs.addSystemWorldScoped(
      "velocity",
      selector: [
        LECSId.self,
        LECSPPosition3d.self,
        LECSVelocity2d.self,
      ],
    ) { world, row, columns in
      let entityId = row.component(at: 0, columns, LECSId.self)
      let position = row.component(at: 1, columns, LECSPPosition3d.self)
      let velocity = row.component(at: 2, columns, LECSVelocity2d.self)

      let newPosition =
        position.position
        + F3(
          x: velocity.velocity.x,
          y: velocity.velocity.y,
          z: 0
        )

      return [entityId, LECSPPosition3d(newPosition), velocity]
    }
  }
  /// Update the game.
  /// - Parameters:
  ///   - timeStep: The amount of time to move it forward.
  func update(timeStep: Float, input: GMGameInput) -> any DSQueue<GMWorldCommands> {
    let playerCamera = ecs.gmCameraFirstPerson("playerCamera")!
    var gameCommands: any DSQueue<GMWorldCommands> = DSQueueArray<GMWorldCommands>()

    var inputEvents: any DSQueue<GMGameInput.Events> = input.events
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

        ecs.addComponent(
          tapSquare!,
          LECSPPosition3d(x: worldLocation.x, y: worldLocation.y, z: worldLocation.z)
        )
        ecs.addComponent(tapSquare!, CTTagTap())
        ecs.addComponent(tapSquare!, LECSPTagVisible())
        if let tapSystem = self.tapSystem {
          ecs.processSystemWorldScoped(system: tapSystem)
        }
        if let collisionSystem = self.collisionSystem {
          ecs.processSystemWorldScoped(system: collisionSystem)
        }
        ecs.removeComponent(tapSquare!, component: CTTagTap.self)
      case .screenSizeChanged:
        break
      }

      let buttonTappable = ecs.getComponent(
        ecs.entity(config.game.world.world02.exitButton)!,
        CTTappable.self
      )!

      if buttonTappable.tapped {
        print("exit button tapped")
        ecs.addComponent(
          ecs.entity(config.game.world.world02.exitButton)!,
          CTTappable(tapped: false)
        )
        gameCommands.enqueue(.start(level: 0))
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
