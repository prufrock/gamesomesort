//
//  GMStartFromTileMapTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/16/25.
//

import Testing
@testable import gamesomesort

import Foundation
import lecs_swift

struct GMStartFromTileMapTests {

  @Test func oneTileTileMap() throws {
    let ecs = LECSCreateWorld(archetypeSize: 10)

    let tileMap = GMTileMap(
      GMMapData(tiles: [.wall], width: 1, things: []),
      index: 0
    )

    let starter = GMStartFromTileMap(map: tileMap)

    starter.start(ecs: ecs)

    var positions: [LECSPosition2d] = []
    ecs.select([LECSPosition2d.self]) { row, columns in
      let position = row.component(at: 0, columns, LECSPosition2d.self)
      positions.append(position)
    }

    #expect(positions.count == 1)
    #expect(positions[0].position == Float2(x: 0, y: 0))
  }
}
