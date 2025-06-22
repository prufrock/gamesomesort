//
//  ControllerInput.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

class ControllerInput {

  // variables for using the touch screen
  private var lastTouchedTime: Double = 0.0
  var touchCoords: F2 = F2()

  // The last time the screen was clicked.
  // Needed so that the mouseLocation isn't constantly sent in as input
  private var lastClickedTime: Double = 0.0
  var mouseLocation: F2 = F2()
}
