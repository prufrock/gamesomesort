//
//  GMWorldFactory.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 2/4/26.
//

import lecs_swift

extension AppCore {
  /// GMWorldFactory is used to create fresh instances of GMWorlds.
  struct GMWorldFactory {
    /// A reference to the main config, for use when creating worlds.
    private let config: AppCoreConfig

    /// A reference to the main config's world attribute--a shortcut.
    /// cw = ConfigWorld
    private var cw: AppCoreConfig.Game.World {
      config.game.world
    }

    /// Create a fresh GMWorldFactory with the given config.
    init(config: AppCoreConfig) {
      self.config = config
    }

    /// Creates a GMWorld for the level based on the levels provided. Level 0
    /// is GMWorld00, level 1 is GMWorld01, and everything else is GMWorld02.
    func create(level: Int, levels: [GMTileMap]) -> any GMWorld {
      var selectedLevel = 0
      if level < levels.count {
        selectedLevel = level
      }
      let map = levels[selectedLevel]
      switch selectedLevel {
      case 0:
        return GMWorld00(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: cw.ecsArchetypeSize),
          map: map,
          ecsStarter: GMEcsInitW00(config: config)
        )
      case 1:
        return GMWorld01(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: cw.ecsArchetypeSize),
          map: map,
          ecsStarter: GMEcsInitW01(map: levels[selectedLevel], config: config)
        )
      default:
        return GMWorld02(
          config: config,
          ecs: LECSCreateWorld(archetypeSize: cw.ecsArchetypeSize),
          map: map,
          ecsStarter: GMEcsInitW02(map: levels[selectedLevel], config: config)
        )
      }
    }
  }
}
