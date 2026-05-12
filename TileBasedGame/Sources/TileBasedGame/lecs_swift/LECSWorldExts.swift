//
//  LECSWorldExts.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/4/26.
//

import lecs_swift
import VRTMath
import LECSPieces

extension LECSWorld {
  func vrtmCameraPerspective(_ name: String) -> VRTMCameraPerspective? {
    guard
      let playerCamera = entity("playerCamera"),
      let cameraComponent = getComponent(playerCamera, LECSPCameraFirstPerson.self),
      let cameraPosition = getComponent(playerCamera, LECSPPosition3d.self),
      let aspectRatio = getComponent(playerCamera, LECSPAspect.self),
      let cameraScale = getComponent(playerCamera, LECSPScale3d.self)
    else {
      return nil
    }
    return VRTMCameraPerspective(
      aspect: aspectRatio.aspect,
      far: cameraComponent.farPlane,
      fov: cameraComponent.fov,
      near: cameraComponent.nearPlane,
      transform: VRTMTransform(
        position: cameraPosition.position,
        quaternion: Float4x4.identity.q,
        scale: cameraScale.scale
      )
    )
  }
}

// Tappables
extension LECSWorld {
  func createTap(
    isVisible: Bool,
    name: String,
    position: F3,
    radius: Float,
  ) {
    let id = createEntity("tapLocation")
    let position = LECSPPosition3d(position)
    let radius = LECSPRadius(radius)
    addComponent(id, position)
    addComponent(id, radius)
    addComponent(id, LECSPTag.Tap())
    addComponent(id, LECSPModel("button-one"))
    addComponent(id, LECSPColor(F3(0, 0, 0)))
    addComponent(id, LECSPScale3d(F3(repeating: radius.radius)))
    addComponent(id, LECSPQuaternion(fromDegY: 0))
    if isVisible {
      addComponent(id, LECSPTag.Visible())
    }
  }

  func getTap(name: String) -> Model.Tap {
    let entity = entity(name)!
    let position = getComponent(entity, LECSPPosition3d.self)!
    let radius = getComponent(entity, LECSPRadius.self)!
    let visible = getComponent(entity, LECSPTag.Visible.self)

    return .init(
      id: entity,
      name: name,
      position: position,
      radius: radius,
      visible: visible
    )
  }

  func selectTappables(
    block: (
      LECSPHUD.Button.Behaviors,
      LECSPPosition3d,
      LECSPRadius
    ) -> Void)
  {
    select([
      LECSPHUD.Button.Behaviors.self,
      LECSPPosition3d.self,
      LECSPRadius.self,
      LECSPTag.Tappable.self
    ]) { row, columns in
      let behaviors = row.component(at: 0, columns, LECSPHUD.Button.Behaviors.self)
      let position = row.component(at: 1, columns, LECSPPosition3d.self)
      let radius = row.component(at: 2, columns, LECSPRadius.self)

      block(behaviors, position, radius)
    }
  }

  func updateTappable(
    model: Model.Tap
  ) {
    addComponent(model.id, model.position)
    addComponent(model.id, model.radius)
  }
}

enum Model {
  struct Tap {
    let id: LECSEntityId
    let name: String
    var position: LECSPPosition3d
    let radius: LECSPRadius
    var rectangle: VRTM2D.Rectangle {
      .init(
        min: F2(
          position.x - radius.radius,
          position.y - radius.radius,
        ),
        max: F2(
          position.x + radius.radius,
          position.y + radius.radius,
        )
      )
    }
    var visible: LECSPTag.Visible?

    mutating func set(position: F3) {
      self.position.position = position
    }

    mutating func show() {
      self.visible = LECSPTag.Visible()
    }

    mutating func hide() {
      self.visible = nil
    }
  }
}
