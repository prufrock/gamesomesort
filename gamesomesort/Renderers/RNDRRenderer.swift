//
//  RNDRRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit
import lecs_swift

protocol RNDRRenderer {
  func resize(_ dimensions: ScreenDimensions)
  func render(ecs: LECSWorld, to renderDescriptor: RenderDescriptor)
}
