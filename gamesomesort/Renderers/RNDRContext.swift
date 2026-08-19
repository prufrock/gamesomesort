//
//  RNDRContext.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/18/26.
//

import MetalKit

// Shared information needed for rendering.
protocol RNDRContext {
  // TODO: remove once moved to the separate light buffers
  var lights: [SHDRLight] { get }
  // TODO: remove once moved to the separate light buffers
  var lightBuffer: MTLBuffer? { get }
  var pointLights: [SHDRLight] { get }
  var pointLightBuffer: MTLBuffer? { get }
  var sunLights: [SHDRLight] { get }
  var sunLightBuffer: MTLBuffer? { get }
  var controllerTexture: ControllerTexture { get }
  var controllerModel: ControllerModel { get }
}
