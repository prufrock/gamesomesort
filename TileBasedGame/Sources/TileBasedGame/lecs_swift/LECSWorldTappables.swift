//
//  LECSWorldTappables.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/17/26.
//

import lecs_swift
import VRTMath
import LECSPieces

// Tappables
extension LECSWorld {
  func createTap(
    isVisible: Bool,
    name: String,
    position: F3,
    radius: Float,
  ) {
    let id = createEntity(name)
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

  func createTappable(
    behaviors: Array<String>,
    color: F3,
    model: String,
    name: String,
    position: F3,
    radius: Float,
    rotationDegY: Float,
    scale: Float,
    tappable: Bool,
    visible: Bool
  ) {
    let entity = createEntity(name)
    addComponent(
      entity, LECSPHUD.Button.Behaviors(Set(behaviors))
    )
    addComponent(entity, LECSPPosition3d(position))
    addComponent(entity, LECSPScale3d(F3(repeating: scale)))
    addComponent(entity, LECSPColor(color))
    addComponent(
      entity,
      LECSPQuaternion(Float4x4.rotateY(rotationDegY).q)
    )
    addComponent(entity, LECSPRadius(radius))
    addComponent(entity, LECSPModel(model))
    if tappable {
      addComponent(entity, LECSPTag.Tappable())
    }
    if visible {
      addComponent(entity, LECSPTag.Visible())
    }
  }

  func selectTappables(
    block: (
      LECSId,
      LECSPHUD.Button.Behaviors,
      LECSPPosition3d,
      LECSPRadius
    ) -> Void)
  {
    select([
      LECSId.self,
      LECSPHUD.Button.Behaviors.self,
      LECSPPosition3d.self,
      LECSPRadius.self,
      LECSPTag.Tappable.self
    ]) { row, columns in
      var i = 0
      let counter: () -> Int = { defer {i += 1}; return i }
      let id = row.component(at: counter(), columns, LECSId.self)
      let behaviors = row.component(at: counter(), columns, LECSPHUD.Button.Behaviors.self)
      let position = row.component(at: counter(), columns, LECSPPosition3d.self)
      let radius = row.component(at: counter(), columns, LECSPRadius.self)

      block(id, behaviors, position, radius)
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
