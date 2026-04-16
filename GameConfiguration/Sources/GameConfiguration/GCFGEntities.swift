//
//  GCFGEntities.swift
//  GameConfiguration
//
//  Created by David Kanenwisher on 4/14/26.
//

public struct GCFGEntities: Decodable {
  public let tiles: [Int: GCFGTile]
  public let creatures: [Int: GCFGCreature]
  public let things: [Int: GCFGThing]

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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    self.tiles = try Self.decodeIntKeyedDictionary(
      forKey: "tiles",
      container: container
    )

    self.creatures = try Self.decodeIntKeyedDictionary(
      forKey: "creatures",
      container: container
    )

    self.things = try Self.decodeIntKeyedDictionary(
      forKey: "things",
      container: container
    )
  }

  private static func decodeIntKeyedDictionary<T: Decodable>(
    forKey key: String,
    container: KeyedDecodingContainer<CodingKeys>,
  ) throws -> [Int: T] {
    let decodedContainer = try container.nestedContainer(
      keyedBy: CodingKeys.self,
      forKey: CodingKeys(stringValue: key)!
    )

    var decodedMap: [Int: T] = [:]
    for key in decodedContainer.allKeys {
      if let intKey = key.intValue {
        decodedMap[intKey] = try decodedContainer.decode(T.self, forKey: key)
      }
    }

    return decodedMap
  }
}
