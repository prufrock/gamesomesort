//
//  StepHandleEventsTests.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 6/14/26.
//

import lecs_swift
import LECSPieces
import Testing
@testable import TileBasedGame

@Suite
struct StepHandleEventsTests {

  private let ecs: LECSWorld
  private let context: StepSelector.Context

  init() {
    let helpers = TestHelpers()
    ecs = LECSCreateWorld(archetypeSize: 100)
    helpers.initComponents(ecs: ecs)
    context = StepSelector.Context(
      ecs: ecs,
      config: Config(level: helpers.levelOneCfg, world: helpers.worldCfg),
      input: TBDGame.Input(),
    )
  }

  @Test func `when nothing happens, no events`() {
    let stepSelector = StepSelector()
    let events = stepSelector.run(context: context)

    #expect(events.count == 0)
  }

  @Test func `when a button is touched with an exit behavior recieve start(level)`() {
    let buttonEntity = ecs.createEntity("buttonEntity")
    ecs.addComponent(buttonEntity, LECSPHUD.Button.Behaviors(["exit"]))

    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .touched(LECSId(buttonEntity))))

    let stepSelector = StepSelector()
    var events = stepSelector.run(context: context)

    #expect(events.count == 1)

    let exitEvent = events.dequeue()!
    #expect(exitEvent.self == .start(level: 0))
  }

  @Test func `when a button is touched with a reload behavior receive startWorld`() {
    let buttonEntity = ecs.createEntity("buttonEntity")
    ecs.addComponent(buttonEntity, LECSPHUD.Button.Behaviors(["reload"]))

    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .touched(LECSId(buttonEntity))))

    let stepSelector = StepSelector()
    var events = stepSelector.run(context: context)

    #expect(events.count == 1)

    let command = events.dequeue()!
    #expect(command.self == .startWorld(world: "world001"))
  }

  @Test func `when there's an awake event remove the timer`() {
    let entity = ecs.createEntity("sleepingEntity")
    ecs.addComponent(entity, LECSPTimerSleep())
    ecs.addComponent(entity, LECSPOnWake())
    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .awake(LECSId(entity))))

    let stepSelector = StepSelector()
    var _ = stepSelector.handleEvents(context: context)

    #expect(ecs.hasComponent(entity, LECSPTimerSleep.self) == false)
  }

  @Test func `when an entity wakes up and creates a creature`() {
    let entity = ecs.createEntity("sleepingEntity")
    ecs.addComponent(entity, LECSPTimerSleep())
    ecs.addComponent(entity, LECSPOnWake([.creates(creatureId: "1")]))
    ecs.addComponent(entity, LECSPPosition3d(0, 0, 0))
    let entityEvent = ecs.createEntity("tapEvent")
    ecs.addComponent(entityEvent, LECSPEvent(event: .awake(LECSId(entity))))

    let stepSelector = StepSelector()
    var _ = stepSelector.handleEvents(context: context)

    var playerCount = 0
    ecs.select([LECSPModel.self]) { row, columns in
      let model = row.component(at: 0, columns, LECSPModel.self)

      if model.name == "player" {
        playerCount += 1
      }
    }

    #expect(playerCount == 1, "One player is created.")
  }
}
