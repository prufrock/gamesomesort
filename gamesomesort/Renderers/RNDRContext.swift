//
//  RNDRContext.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 8/18/26.
//

import MetalKit

// Shared information needed for rendering.
protocol RNDRContext {
  var pointLights: [SHDRLight] { get }
  var pointLightBuffer: MTLBuffer? { get }
  var sunLights: [SHDRLight] { get }
  var sunLightBuffer: MTLBuffer? { get }
  var controllerTexture: ControllerTexture { get }
  var controllerModel: ControllerModel { get }
}
