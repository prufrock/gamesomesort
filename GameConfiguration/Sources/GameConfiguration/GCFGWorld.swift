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
  public let worldVector: F3

  public struct HUD: Decodable {
    public let buttons: [Button]

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
    }
  }

  public struct LevelPath: Decodable {
    public let name: String
    public let path: String
  }
}
