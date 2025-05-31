//
//  RNDRRenderer.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import Foundation
import MetalKit

protocol RNDRRenderer {
  func resize(view: MTKView, size: CGSize)
  func render(to view: MTKView)
}
