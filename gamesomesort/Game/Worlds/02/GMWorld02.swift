//
//  World.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/2/25.
//

import DataStructures
import Foundation
import lecs_swift

class GMWorld02: GMWorld {
  private let config: AppCoreConfig
  public let ecs: LECSWorld
  private(set) var map: GMTileMap
  private let ecsStarter: GMEcsStarter
  private var screenDimensions = ScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)
  public var basis: F3 {
    config.game.world.world02.worldBasis
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
    ecs.addComponent(tapSquare, CTTagVisible())
    ecs.addComponent(tapSquare, CTModel("button-one"))
    ecs.addComponent(tapSquare, CTQuaternion(simd_quatf(Float4x4.identity)))
    ecs.addComponent(tapSquare, CTScale3d(F3(repeating: 0.1)))
    self.tapSquare = tapSquare

    aspectRatioSystem = ecs.addSystem("aspectRatio", selector: [CTAspect.self]) { components, columns in
      return [CTAspect(aspect: self.screenDimensions.aspectRatio)]
    }

    collisionSystem = ecs.addSystemWorldScoped(
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

    tapSystem = ecs.addSystemWorldScoped(
      "tapSystem",
      selector: [
        LECSId.self,
        CTPosition3d.self,
        CTTagTap.self,
      ]
    ) { world, row, columns in
      let tapEntityId = row.component(at: 0, columns, LECSId.self)
      let tapPosition = row.component(at: 1, columns, CTPosition3d.self)

      world.select(
        [LECSId.self, CTPosition3d.self, CTRadius.self, CTTappable.self]
      ) { otherRow, otherColumns in
        let otherEntityId = otherRow.component(at: 0, otherColumns, LECSId.self)
        let otherPosition = otherRow.component(at: 1, otherColumns, CTPosition3d.self)
        let otherRadius = otherRow.component(at: 2, otherColumns, CTRadius.self)
        let otherRectangle = GEORectangle(
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

        ecs.addComponent(tapSquare!, CTPosition3d(x: worldLocation.x, y: worldLocation.y, z: 1.0))
        ecs.addComponent(tapSquare!, CTTagTap())
        ecs.addComponent(tapSquare!, CTTagVisible())
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

      var lastEventId: LECSId? = nil
      ecs.select([LECSId.self, CTTappable.self, LECSName.self]) { row, columns in
        let id = row.component(at: 0, columns, LECSId.self)
        let tappable = row.component(at: 1, columns, CTTappable.self)
        let name = row.component(at: 2, columns, LECSName.self)

        // Could this happen, instead of setting tapped?
        if tappable.tapped {
          print("tapped name \(name)")
          var eventName: String
          if lastEventId == nil {
            eventName = "eventStart"
          } else {
            eventName = "event\(lastEventId?.id ?? 0)"
          }
          let newEvent = ecs.createEntity(eventName)
          ecs.addComponent(
            newEvent,
            CTEvent(
              nextEventId: nil,
              srcEntity: id,
              type: .tap
            )
          )
          if let lastEventId {
            let lastEvent = ecs.getComponent(
              lastEventId.id,
              CTEvent.self
            )
            if let lastEvent {
              ecs.addComponent(lastEventId.id, lastEvent)
            }
          }
          lastEventId = LECSId(newEvent)

          ecs.addComponent(
            id.id,
            CTTappable(tapped: false)
          )
        }
      }
    }

    let playerPosition = ecs.getComponent(
      ecs.entity("player01")!,
      CTPosition3d.self
    )!
    var playerSafe = false
    ecs.select([CTTile.self, CTPosition3d.self]) { row, columns in
      let tile = row.component(at: 0, columns, CTTile.self)
      let tilePosition = row.component(at: 1, columns, CTPosition3d.self)
      if playerSafe == false && tile.tile == .floor {
        playerSafe = tilePosition.position.xy == playerPosition.position.xy
      }
    }

    if !playerSafe {
      print("Restart level.")
      let startId = ecs.entity("start")!
      let startPosition = ecs.getComponent(startId, CTPosition3d.self)!
      ecs.addComponent(
        ecs.entity("player01")!,
        startPosition
      )

      ecs.select([LECSId.self, CTLockingButton.self]) { row, columns in
        let entityId = row.component(at: 0, columns, LECSId.self)
        var buttonLock = row.component(at: 1, columns, CTLockingButton.self)
        buttonLock.count = 0
        buttonLock.locked = false
        let buttonColor: GMColor = .green
        ecs.addComponent(entityId.id, buttonLock)
        ecs.addComponent(entityId.id, CTColor(buttonColor))
      }
    }

    var goalReached = false
    ecs.select([CTThing.self, CTPosition3d.self]) { row, columns in
      let thing = row.component(at: 0, columns, CTThing.self)
      let tilePosition = row.component(at: 1, columns, CTPosition3d.self)
      if goalReached == false && thing.thing == .end {
        goalReached = tilePosition.position.xy == playerPosition.position.xy
      }
    }

    if goalReached {
      print("Goal reached.")
      gameCommands.enqueue(.start(level: map.index + 1))
    }

    if let velocitySystem {
      ecs.processSystemWorldScoped(system: velocitySystem)
    }

    var eventId: LECSEntityId? = ecs.entity("eventStart")

    while let validId = eventId {
      let event: CTEvent? = ecs.getComponent(validId, CTEvent.self)
      ecs.deleteEntity(validId)
      eventId = event?.nextEventId?.id

      if let event = event {
        let buttonName = ecs.getComponent(
          event.srcEntity.id,
          LECSName.self
        )!
        print("eventId: \(validId), srcEntity: \(event.srcEntity), buttonName \(buttonName)")
        if buttonName.name.starts(with: "exit") {
          gameCommands.enqueue(.start(level: 0))
        }

        if buttonName.name.starts(with: "edit") {
          let color = ecs.getComponent(event.srcEntity.id, CTColor.self)!
          // store the state in the color for expediency!
          if color.f3.x <= 0 {
            ecs.addComponent(event.srcEntity.id, CTColor(F3(0.5, 0.25, 0)))
          } else {
            ecs.addComponent(event.srcEntity.id, CTColor(F3(0, 0, 0)))
          }
        }

        if buttonName.name.starts(with: "tile")
          && ecs.getComponent(ecs.entity("editButton")!, CTColor.self)!.color.r > 0
        {
          var tile = ecs.getComponent(event.srcEntity.id, CTTile.self)!
          if tile.tile == .floor {
            let pos = ecs.getComponent(event.srcEntity.id, CTPosition3d.self)!
            ecs.addComponent(event.srcEntity.id, CTPosition3d(pos.x, pos.y, 1.0))
            ecs.addComponent(event.srcEntity.id, CTRadius(0.5))
            ecs.addComponent(event.srcEntity.id, CTColor(.green))
            ecs.addComponent(event.srcEntity.id, CTScale3d(F3(x: 1, y: 1, z: 1)))
            tile = CTTile(.wall)
          } else if tile.tile == .wall {
            tile = CTTile(.floor)
            let pos = ecs.getComponent(event.srcEntity.id, CTPosition3d.self)!
            ecs.addComponent(event.srcEntity.id, CTPosition3d(pos.x, pos.y, 1.8))
            ecs.addComponent(event.srcEntity.id, CTRadius(0.5))
            ecs.addComponent(event.srcEntity.id, CTColor(.yellow))
            ecs.addComponent(event.srcEntity.id, CTScale3d(F3(x: 0.9, y: 0.9, z: 0.9)))
          }
          ecs.addComponent(event.srcEntity.id, tile)
        }

        // increment taps
        if ecs.hasComponent(event.srcEntity.id, CTLockingButton.self) {
          var buttonLock = ecs.getComponent(event.srcEntity.id, CTLockingButton.self)!
          if buttonLock.locked == false {
            movePlayer(
              ecs: ecs,
              buttonName: buttonName.name,
              startsWith: "r",
              add: F3(x: 1.0, y: 0.0, z: 0.0)
            )
            movePlayer(
              ecs: ecs,
              buttonName: buttonName.name,
              startsWith: "l",
              add: F3(x: -1.0, y: 0.0, z: 0.0)
            )
            movePlayer(
              ecs: ecs,
              buttonName: buttonName.name,
              startsWith: "d",
              add: F3(x: 0.0, y: 1.0, z: 0.0)
            )
            movePlayer(
              ecs: ecs,
              buttonName: buttonName.name,
              startsWith: "u",
              add: F3(x: 0.0, y: -1.0, z: 0.0)
            )
            // decrement locks before locking to avoid incrementing the current button, also only unlocked buttons can incremented
            ecs.select([LECSId.self, CTLockingButton.self]) { row, columns in
              let entityId = row.component(at: 0, columns, LECSId.self)
              var buttonLock = row.component(at: 1, columns, CTLockingButton.self)

              if buttonLock.locked {
                buttonLock.count += 1
              }

              if buttonLock.count == 0 {
                buttonLock.locked = false
              }

              // adjust color
              var buttonColor: GMColor
              if buttonLock.count == 0 {
                buttonColor = .green
              } else if buttonLock.count == 1 {
                buttonColor = .yellow
              } else if buttonLock.count == 2 {
                buttonColor = .red
              } else if buttonLock.count == -3 {
                buttonColor = .black
              } else if buttonLock.count == -2 {
                buttonColor = .grey
              } else if buttonLock.count == -1 {
                buttonColor = .blue
              } else {
                buttonColor = .black
              }

              ecs.addComponent(entityId.id, buttonLock)
              ecs.addComponent(entityId.id, CTColor(buttonColor))
            }
            buttonLock.count += 1
            if buttonLock.count == 3 {
              buttonLock.locked = true
              buttonLock.count = -3
            }
          }

          ecs.addComponent(event.srcEntity.id, buttonLock)
          // adjust color
          var buttonColor: GMColor
          if buttonLock.count == 0 {
            buttonColor = .green
          } else if buttonLock.count == 1 {
            buttonColor = .yellow
          } else if buttonLock.count == 2 {
            buttonColor = .red
          } else if buttonLock.count == -3 {
            buttonColor = .black
          } else if buttonLock.count == -2 {
            buttonColor = .grey
          } else if buttonLock.count == -1 {
            buttonColor = .blue
          } else {
            buttonColor = .black
          }
          ecs.addComponent(event.srcEntity.id, CTColor(buttonColor))
        }
      }
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

  func movePlayer(
    ecs: LECSWorld,
    buttonName: String,
    startsWith: String,
    add: F3
  ) {
    if buttonName.starts(with: startsWith) {
      let playerPosition = ecs.getComponent(
        ecs.entity("player01")!,
        CTPosition3d.self
      )!

      ecs.addComponent(
        ecs.entity("player01")!,
        playerPosition + add
      )
    }
  }
}
