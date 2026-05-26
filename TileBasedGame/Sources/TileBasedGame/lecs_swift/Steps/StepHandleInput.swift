//
//  StepInputHandler.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/25/26.
//

import VRTMath

extension StepSelector {
  func handleInput(context ctx: Context) -> GameCommands {
    let ecs = ctx.ecs
    let input = ctx.input
    let screenDimensions = input.screenDimensions

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

    return GameCommands()
  }
}
