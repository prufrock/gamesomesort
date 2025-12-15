//
//  GMWorld.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 11/30/25.
//
import lecs_swift

protocol GMWorld {

  var ecs: LECSWorld { get }

  var basis: F3 { get }

  func update(timeStep: Float, input: GMGameInput) -> any CTSQueue<GMWorldCommands>

  func update(_ dimensions: ScreenDimensions)
}

enum GMWorldCommands: Equatable {
  case start(level: Int)
}
