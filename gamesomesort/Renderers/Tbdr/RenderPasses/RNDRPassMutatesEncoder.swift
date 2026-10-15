//
//  RNDRPassMutatesEncoder.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 10/15/26.
//

import Metal

protocol RNDRPassRendersSingleOrInstancedEncoder {
  func renderIndividual(renderEncoder: MTLRenderCommandEncoder)

  func renderInstanced(renderEncoder: MTLRenderCommandEncoder)
}
