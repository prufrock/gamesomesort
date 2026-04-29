//
//  TBDGWorldTests.swift
//  TileBasedGame
//
//  Created by David Kanenwisher on 4/28/26.
//

import Foundation
import GameConfiguration
import lecs_swift
import LECSPieces
import Testing
import VRTMath
@testable import TileBasedGame


@Test func `load the world`() {
  let worldCfg: GCFGWorld = try! loadTestFile(
    from: "WorldOneLevel",
    name: "world_one_level"
  )

  let levelOneCfg: GCFGLevel = try! loadTestFile(
    from: "WorldOneLevel",
    name: worldCfg.levels["world_one_level_001"]!.path
  )

  let ecs = LECSCreateWorld(archetypeSize: 100)

  let world = TBDGWorld(
    worldConfig: worldCfg,
    levelConfig: levelOneCfg,
    ecs: ecs
  )
  world.reset()

  _ = {
    let entity = world.ecs.entity("playerCamera")!

    let aspect = world.ecs.getComponent(
      entity,
      LECSPAspect.self
    )!
    #expect(aspect == 1.0)

    let camera = world.ecs.getComponent(
      entity,
      LECSPCameraFirstPerson.self
    )
    #expect(camera != nil)

    let position = world.ecs.getComponent(
      entity,
      LECSPPosition3d.self
    )!
    #expect(position == [0, 0, 0])

    let scale = world.ecs.getComponent(
      entity,
      LECSPScale3d.self
    )!
    #expect(scale == [1, -1, 1])
  }()

  world.update(VRTMScreenDimensions(
    pixelSize: CGSize(width: 300, height: 500),
    scaleFactor: 1.0)
  )

  _ = {
    let entity = world.ecs.entity("playerCamera")!

    let aspect = world.ecs.getComponent(
      entity,
      LECSPAspect.self
    )!
    #expect(aspect == 0.6)
  }()
}

private func loadTestFile<T: Decodable>(from dir: String, name: String) throws -> T {
  let bundle = Bundle.module
  let jsonUrl = bundle.url(
    forResource: "Resources/\(dir)/\(name)",
    withExtension: "json"
  )!

  let data: Data = try! Data(contentsOf: jsonUrl)
  return try JSONDecoder().decode(T.self, from: data)
}
