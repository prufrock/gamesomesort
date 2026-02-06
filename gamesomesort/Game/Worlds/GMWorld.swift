//
//  GMWorld.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 11/30/25.
//
import DataStructures
import lecs_swift

protocol GMWorld {

  var ecs: LECSWorld { get }

  var basis: F3 { get }
  var uprightTransforms: [String: GEOTransform] { get }

  func update(timeStep: Float, input: GMGameInput) -> any DSQueue<GMWorldCommands>

  func update(_ dimensions: ScreenDimensions)
}

enum GMWorldCommands: Equatable {
  case start(level: Int)
}
