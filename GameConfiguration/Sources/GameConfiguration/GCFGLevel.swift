//
//  GCFGLevel.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/6/26.
//

import VRTMath

public struct GCFGLevel: Decodable {
  public let map: Map
  public let playerCamera: Camera
  public let sun: Light.Sun

  public init(
    map: Map,
    playerCamera: Camera,
    sun: Light.Sun
  ) {
    self.map = map
    self.playerCamera = playerCamera
    self.sun = sun
  }

  public subscript(creature x: Int, y: Int) -> Int? {
    get { map.creatures[y * map.width + x] }
  }

  public subscript(tile x: Int, y: Int) -> Int? {
    get { map.tiles[y * map.width + x] }
  }

  public subscript(thing x: Int, y: Int) -> Int? {
    get { map.things[y * map.width + x] }
  }

  public struct Camera: Decodable {
    public let farPlane: Float
    public let nearPlane: Float
    public let position: F3
    public let viewAngleDegrees: Float

    public init(
      farPlane: Float,
      nearPlane: Float,
      position: F3,
      viewAngleDegrees: Float,
    ) {
      self.farPlane = farPlane
      self.nearPlane = nearPlane
      self.position = position
      self.viewAngleDegrees = viewAngleDegrees
    }
  }

  public enum Light {
    public struct Sun: Decodable {
      public let color: F3
      public let position: F3

      public init(
        color: F3,
        position: F3
      ) {
        self.color = color
        self.position = position
      }
    }
  }

  public struct Map: Decodable {
    // creatures have behaviors like players and monsters
    public let creatures: [Int]
    // for now, things are everything that isn't tiles or creatures
    public let things: [Int]
    // tiles are the walls, floors, pits, that make up the world
    public let tiles: [Int]
    public let width: Int
    public var height: Int {
      width
    }

    public init(
      creatures: [Int],
      things: [Int],
      tiles: [Int],
      width: Int,
    ) {
      self.width = width
      self.tiles = tiles
      self.creatures = creatures
      self.things = things
    }

    public subscript(creature x: Int, y: Int) -> Int {
      get { creatures[y * width + x] }
    }

    public subscript(tile x: Int, y: Int) -> Int {
      get { tiles[y * width + x] }
    }

    public subscript(thing x: Int, y: Int) -> Int {
      get { things[y * width + x] }
    }

    public func forEachLocation(_ body: (Int, Int) -> Void) {
      for y in 0..<height {
        for x in 0..<width {
          body(x, y)
        }
      }
    }
  }
}
