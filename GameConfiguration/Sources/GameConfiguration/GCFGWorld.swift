//
//  GCFGWorld.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/5/26.
//

public struct GCFGWorld: Decodable {
  public let entities: GCFGEntities
  public let levels: [String: LevelPath]
  public let name: String

  public struct LevelPath: Decodable {
    public let name: String
    public let path: String
  }
}
