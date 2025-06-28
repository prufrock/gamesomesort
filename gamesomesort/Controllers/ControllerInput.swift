//
//  ControllerInput.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

import Foundation
import Combine
import MetalKit

class ControllerInput {
  let config: AppCoreConfig

  private var tapLocationSubject: PassthroughSubject<CGPoint, Never> = PassthroughSubject<CGPoint, Never>()
  private var tapLocationCancelable: AnyCancellable?

  private var lastTouchedTime: Double = 0.0
  private var touchCoords: F2 = F2()
  private var touched: Bool = false

  init(config: AppCoreConfig) {
    self.config = config
    setupTapLocationSubscribers()
  }

  /// Only initializes the subject if the cancellable does not exist. If for some reason tapping stops working it may because it was cancelled when
  /// the view was backgrounded or something. Keep an eye out for issues with that and you may learn something!
  private func setupTapLocationSubscribers() {
    if tapLocationCancelable != nil {
      return
    }

    tapLocationCancelable =
      tapLocationSubject
      .debounce(for: .milliseconds(config.game.tapDelay), scheduler: RunLoop.main)
      .sink(
        receiveCompletion: { completion in
          fatalError(
            "ControllerInput::tapLocationSubject received completion: \(completion)."
              + "You left this here, so you would know when the subscription dies."
              + "A likely fix might be to either nil the cancellable or store in a set of cancellables."
              + "Either way you need to make sure the subscription is started again."
          )
        },
        receiveValue: { [weak self] location in
          guard let self else { return }
          self.touchCoords = F2(location.x.f, location.y.f)
          self.lastTouchedTime = CACurrentMediaTime()
          self.touched = true
          print("recieved tap at \(location)")
        }
      )
  }

  func updateTapLocation(_ location: CGPoint) {
    tapLocationSubject.send(location)
  }

  func update() -> GMGameInput {
    defer {
      touched = false
    }

    return GMGameInput(tapLocation: touchCoords, lastTapTime: lastTouchedTime, tapped: touched)
  }
}

struct GMGameInput {
  let tapLocation: F2
  let lastTapTime: Double
  let tapped: Bool
}
