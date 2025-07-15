//
//  SVCRenderDescriptor.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 7/14/25.
//

import MetalKit

struct SVCRenderDescriptor {
  let view: MTKView
  let currentRenderPassDescriptor: MTLRenderPassDescriptor
  let currentDrawable: MTLDrawable
}
