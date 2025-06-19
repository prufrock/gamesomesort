//
//  CTColor.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/18/25.
//
import lecs_swift

struct CTColor: LECSComponent {
  var color: GMColorA

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
}
