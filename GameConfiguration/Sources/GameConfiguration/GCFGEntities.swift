//
//  GCFGEntities.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/14/26.
//

struct GCFGEntities: Decodable {
  let tiles: [Int: GCFGTile]

  private struct CodingKeys: CodingKey {
    var intValue: Int?
    var stringValue: String

    init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = Int(stringValue)
    }

    init?(intValue: Int) {
      self.stringValue = String(intValue)
      self.intValue = intValue
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let tilesContainer = try container.nestedContainer(
      keyedBy: CodingKeys.self,
      forKey: CodingKeys(stringValue: "tiles")!
    )

    var tiles: [Int: GCFGTile] = [:]
    for key in tilesContainer.allKeys {
      if let intKey = key.intValue {
        tiles[intKey] = try tilesContainer.decode(GCFGTile.self, forKey: key)
      }
    }
    self.tiles = tiles
  }
}
