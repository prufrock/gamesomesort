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
  func resize(size: CGSize)
  func render(ecs: LECSWorld, to renderDescriptor: RenderDescriptor)
}
