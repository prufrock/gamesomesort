//
//  CTColor.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/18/25.
//
import lecs_swift

struct CTColor: LECSComponent {
  var color: GMColorA

  var f3: Float3 {
    Float3(x: color.r, y: color.g, z: color.b)
  }

  init() {
    let temp: GMColor = .white
    color = temp.a()
  }

  init(color: GMColorA) {
    self.color = color
  }

  init(_ color: GMColor, a: Float = 1.0) {
    self.color = color.a(a)
  }

  init(_ color: Float3) {
    self.color = .init(r: color.x, g: color.y, b: color.z, a: 1.0)
  }
}
