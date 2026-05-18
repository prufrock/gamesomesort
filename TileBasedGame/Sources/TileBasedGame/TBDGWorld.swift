//
//  TBDGWorld.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/16/26.
//

import DataStructures
import lecs_swift
import Foundation
import GameConfiguration
import VRTMath
import LECSPieces

public let E_NAME_CAMERA_PLAYER = "playerCamera"
public let E_NAME_TAP_LOCATION = "tapLocation"

public class TBDGWorld {
  public let ecs: LECSWorld
  let worldConfig: GCFGWorld
  let levelConfig: GCFGLevel
  private var screenDimensions = VRTMScreenDimensions(pixelSize: CGSize(), scaleFactor: 1.0)

  public init(
    worldConfig: GCFGWorld,
    levelConfig: GCFGLevel,
    ecs: LECSWorld
  ) {
    self.ecs = ecs
    self.worldConfig = worldConfig
    self.levelConfig = levelConfig
  }

  public func restart() {
    let lvlInit = TBDGLevel(world: self, level: "")
    lvlInit.reset()
  }

  public func update(_ dimensions: VRTMScreenDimensions) {
    let activeCamera = ecs.entity(E_NAME_CAMERA_PLAYER)!
    self.screenDimensions = dimensions

    ecs.addComponent(
      activeCamera,
      LECSPAspect(aspect: dimensions.aspectRatio)
    )
  }

  public func update(
    timeStep: Float,
    input: TBDGame.Input
  ) -> any DSQueue<TBDGWorld.Commands> {
    let activeCamera = ecs.vrtmCameraPerspective(E_NAME_CAMERA_PLAYER)!
    
    var inputEvents = input.events
    while !inputEvents.isEmpty {
      let event = inputEvents.dequeue()!
      switch event {
      case .tap(tapLocation: let loc, lastTapTime: _):
        let worldLocation = TBDGTapLocation(
          location: loc
        ).screenToWorldOnZPlane(
          screenDimensions: screenDimensions,
          targetZPlaneWorldCoord: 1,
          camera: activeCamera,
        )!

        var tap = ecs.getTap(name: E_NAME_TAP_LOCATION)
        tap.set(position: worldLocation)
        tap.show()
        ecs.updateTappable(model: tap)

        ecs.selectTappables { id, behaviors, position, radius in
          let rectangle = VRTM2D.Rectangle(
            position: position.position.xy,
            radius: radius.radius
          )

          let tapped = rectangle.intersection(with: tap.rectangle) != nil
          if tapped {
            ecs.createEvent(name: "tapEvent-\(id)", type: .touched(id))
          }
        }
      case .screenSizeChanged:
        break
      }
    }

    // process events
    return ecs.processEvents()
  }
}

