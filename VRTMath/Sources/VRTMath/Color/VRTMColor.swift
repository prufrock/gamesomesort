//
//  VRTMColor.swift
//  VRTMath
//
//  Created by David Kanenwisher on 4/23/26.
//

import MetalKit

public enum VRTMColor: Int {
  case black = 0x000000
  case red = 0xFF0000
  case green = 0x00FF00
  case blue = 0x0000FF
  case white = 0xFFFFFF
  case grey = 0x808080
  case orange = 0xff8c00
  case yellow = 0xffff00

  // shift to the right x places
  // then only take FF(the two right most hex digits or 8 most bits)
  public func r() -> Int {
    rawValue >> 16 & 0xFF
  }

  public func g() -> Int {
    rawValue >> 8 & 0xFF
  }

  public func b() -> Int {
    rawValue >> 0 & 0xFF
  }

  public func rFloat() -> Float {
    Float(r()) / 255.0
  }

  public func gFloat() -> Float {
    Float(g()) / 255.0
  }

  public func bFloat() -> Float {
    Float(b()) / 255.0
  }

  public func a() -> VRTMColorA {
    VRTMColorA(self)
  }

  public func a(_ a: Float) -> VRTMColorA {
    VRTMColorA(self, a: a)
  }
}

public extension F3 {
  init(_ color: VRTMColor) {
    self.init(color.rFloat(), color.gFloat(), color.bFloat())
  }
}

public extension F4 {
  init(_ color: VRTMColor) {
    self.init(color.rFloat(), color.gFloat(), color.bFloat(), 1.0)
  }

  init(_ color: VRTMColor, alpha: Float) {
    self.init(color.rFloat(), color.gFloat(), color.bFloat(), alpha)
  }

  init(_ color: VRTMColorA) {
    self.init(color.r, color.g, color.b, color.a)
  }
}

public extension MTLClearColor {
  init(_ color: VRTMColor) {
    self.init(red: Double(color.rFloat()), green: Double(color.gFloat()), blue: Double(color.bFloat()), alpha: 1.0)
  }
}

/// Color with alpha.
public class VRTMColorA {
  public let r: Float
  public let g: Float
  public let b: Float
  public let a: Float

  public var F4: F4 {
    Float4(r, g, b, a)
  }

  public var F3: F3 {
    Float3(r, g, b)
  }

  public init(r: Float, g: Float, b: Float, a: Float) {
    self.r = r
    self.g = g
    self.b = b
    self.a = a
  }

  public init(_ color: VRTMColor, a: Float = 1.0) {
    r = color.rFloat()
    g = color.gFloat()
    b = color.bFloat()
    self.a = a
  }
}
