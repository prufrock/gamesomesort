//
//  GCFGLevel.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/6/26.
//

import VRTMath

public struct GCFGLevel: Decodable {
  public let playerCamera: Camera
  public let map: Map

  public subscript(tile x: Int, y: Int) -> Int? {
    get { map.tiles[y * map.width + x] }
  }

  public subscript(creature x: Int, y: Int) -> Int? {
    get { map.creatures[y * map.width + x] }
  }

  public subscript(thing x: Int, y: Int) -> Int? {
    get { map.things[y * map.width + x] }
  }

  public struct Camera: Decodable {
    public let viewAngleDegrees: Float
    public let nearPlane: Float
    public let farPlane: Float
  }

  public struct Light {
    public struct Sun: Decodable {
      public let color: F3
      public let position: F3
    }
  }

  public struct Map: Decodable {
    public let width: Int
    // tiles are the walls, floors, pits, that make up the world
    public let tiles: [Int]
    // creatures have behaviors like players and monsters
    public let creatures: [Int]
    // for now, things are everything that isn't tiles or creatures
    public let things: [Int]

    public subscript(tile x: Int, y: Int) -> Int {
      get { tiles[y * width + x] }
    }

    public subscript(creature x: Int, y: Int) -> Int {
      get { creatures[y * width + x] }
    }

    public subscript(thing x: Int, y: Int) -> Int {
      get { things[y * width + x] }
    }
  }
}
