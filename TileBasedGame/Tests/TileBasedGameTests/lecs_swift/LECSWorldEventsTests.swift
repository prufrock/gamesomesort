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

@Suite
struct LECSWorldEventsTests {

  private let ecs: LECSWorld

  init() {
    ecs = LECSCreateWorld(archetypeSize: 100)

    let componentHolder = ecs.createEntity("componentHolder")
    ecs.addComponent(componentHolder, LECSPEvent())
    ecs.removeComponent(componentHolder, component: LECSPEvent.self)
  }

  @Test func `when nothing happens, no events`() {
    let events = ecs.processEvents()

    #expect(events.count == 0)
  }

  @Test func `when a button is touched with an exit behavior recieve start(level)`() {
    let buttonEntity = ecs.createEntity("buttonEntity")
    ecs.addComponent(buttonEntity, LECSPHUD.Button.Behaviors(["exit"]))

    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .touched(LECSId(buttonEntity))))

    var events = ecs.processEvents()

    #expect(events.count == 1)

    let exitEvent = events.dequeue()!
    #expect(exitEvent.self == .start(level: 0))
  }

  @Test func `when a button is touched with a reload behavior receive startWorld`() {
    let buttonEntity = ecs.createEntity("buttonEntity")
    ecs.addComponent(buttonEntity, LECSPHUD.Button.Behaviors(["reload"]))

    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .touched(LECSId(buttonEntity))))

    var events = ecs.processEvents()

    #expect(events.count == 1)

    let command = events.dequeue()!
    #expect(command.self == .startWorld(world: "world001"))
  }
}

