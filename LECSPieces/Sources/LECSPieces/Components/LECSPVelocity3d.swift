//
//  LECSPVelocity3d.swift
//  LECSPieces
//
//  Created by David Kanenwisher on 10/25/26.
//

import lecs_swift
import VRTMath

public struct LECSPVelocity3d: LECSComponent, Equatable {
    public var velocity: F3

    public init() {
      velocity = F3(x: 0, y: 0, z: 0)
    }

    public init(x: Float, y: Float = 0, z: Float) {
      velocity = F3(x: x, y: y, z: z)
    }

    public init(_ x: Float, _ y: Float, _ z: Float) {
      self.init(x: x, y: y, z: z)
    }

    public init(_ velocity: F3) {
        self.velocity = velocity
    }

    public var x: Float {
        velocity.x
    }
    public var y: Float {
        velocity.y
    }
}
