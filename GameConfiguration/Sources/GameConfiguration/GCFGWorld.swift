//
//  GCFGWorld.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

import VRTMath

public struct GCFGWorld: Decodable {
  public let entities: GCFGEntities
  public let hud: HUD
  public let levels: [String: LevelPath]
  public let name: String
  public let stepList: [GCFGWorld.StepId]
  public let worldVector: F3

  public subscript(thing id: Int) -> GCFGThing? {
    get { entities.things[id] }
  }

  public subscript(creature id: Int) -> GCFGCreature? {
    get { entities.creatures[id] }
  }

  public init(
    entities: GCFGEntities,
    hud: HUD,
    levels: [String : LevelPath],
    name: String,
    stepList: [GCFGWorld.StepId],
    worldVector: F3
  ) {
    self.entities = entities
    self.hud = hud
    self.levels = levels
    self.name = name
    self.stepList = stepList
    self.worldVector = worldVector
  }
}

extension GCFGWorld {
  public struct LevelPath: Decodable {
    public let name: String
    public let path: String

    public init(name: String, path: String) {
      self.name = name
      self.path = path
    }
  }
}

extension GCFGWorld {
  public struct HUD: Decodable {
    public let buttons: [Button]
    public let input: Input

    public init(buttons: [Button], input: Input) {
      self.buttons = buttons
      self.input = input
    }
  }
}

extension GCFGWorld.HUD {
  public struct Button: Decodable {
    public let behaviors: [String]
    public let color: F3
    public let name: String
    public let model: String
    public let position: F3
    public let radius: Float
    public let rotationDegrees: Float
    public let tappable: Bool
    public let visible: Bool

    public init(
      behaviors: [String],
      color: F3,
      name: String,
      model: String,
      position: F3,
      radius: Float,
      rotationDegrees: Float,
      tappable: Bool,
      visible: Bool
    ) {
      self.behaviors = behaviors
      self.color = color
      self.name = name
      self.model = model
      self.position = position
      self.radius = radius
      self.rotationDegrees = rotationDegrees
      self.tappable = tappable
      self.visible = visible
    }
  }
}

extension GCFGWorld.HUD {
  public struct Input: Decodable {
    public let tap: Tap

    public init(tap: Tap) {
      self.tap = tap
    }
  }
}

extension GCFGWorld.HUD.Input {
  public struct Tap: Decodable {
    public let radius: Float

    public init(radius: Float) {
      self.radius = radius
    }
  }
}

extension GCFGWorld {
  public enum StepId: String, Decodable, Hashable {
    case awaken
    case handleEvents
    case handleInput
  }
}
