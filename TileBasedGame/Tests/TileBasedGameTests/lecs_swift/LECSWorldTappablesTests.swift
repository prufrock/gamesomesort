//
//  LECSWorldEventsTests.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 5/17/26.
//

import lecs_swift
import LECSPieces
import Testing
@testable import TileBasedGame
import VRTMath

@Suite
struct LECSWorldTappablesTests {

  private let ecs: LECSWorld

  init() {
    ecs = LECSCreateWorld(archetypeSize: 100)
    let placeholderName = "placeHolder"
    ecs.createTap(
      isVisible: false,
      name: placeholderName,
      position: [0,0,0],
      radius: 0.0
    )
    ecs.deleteEntity(ecs.entity(placeholderName)!)
  }

  @Test func `when no tappables, nothing is selected`() {
    var tappables = Array<LECSId>()

    ecs.createTappable(
        color: F3(0,0,0),
        model: "button",
        name: "button",
        onTap: [],
        position: F3(0,0,0),
        radius: 0.0,
        rotationDegY: 0,
        scale: 0,
        tappable: true,
        visible: true
      )

    ecs.selectTappables { id, _, _, _ in
      tappables.append(id)
    }

    #expect(tappables.count == 1)
  }
}

