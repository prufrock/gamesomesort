//
//  INTapLocation.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/29/25.

// Represents a tp location on the screen.
struct INTapLocation {
  let location: F2

  /// Converts from screen to NDC.
  /// - Parameters:
  /// - screenWidth: The width of the screen that corresponds with the coordinates.
  /// - screenHeight: The height of the screen that corresponds with the coordinates.
  /// - flipY: macOS has an origin in the lower left while iOS has the origin in the upper right so you need to flip y.
  /// - Returns:
  func screenToNdc(screenWidth: Float, screenHeight: Float, flipY: Bool = true) -> Float2 {
    // divide position.x by the screenWidth so number varies between 0 and 1
    // multiply that by 2 so that it varies between 0 and 2
    // subtract 1 because NDC x increases as you go to the right and this moves the value between -1 and 1.
    // remember the abs(-1 - 1) = 2 so multiplying by 2 is important
    let x = ((location.x / screenWidth) * 2) - 1
    // converting position.y is like converting position.x
    // multiply by -1 when flipY is set because on iOS the origin is in the upper left
    let y = (flipY ? -1 : 1) * (((location.y / screenHeight) * 2) - 1)
    // print("click screen:", String(format: "%.8f, %.8f", self.x, self.y))
    // print("click NDC:", String(format: "%.8f, %.8f", x, y))
    return Float2(x, y)  // ndc space
  }
}
