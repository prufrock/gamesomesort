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
  private var cancellables = Set<AnyCancellable>()

  private var lastTouchedTime: Double = 0.0
  private var touchCoords: F2 = F2()

  init(config: AppCoreConfig) {
    self.config = config
    setupTapLocationSubscribers()
  }

  private func setupTapLocationSubscribers() {
    tapLocationSubject
      .debounce(for: .milliseconds(config.game.tapDelay), scheduler: RunLoop.main)
      .sink { [weak self] location in
        guard let self else { return }
        self.touchCoords = F2(location.x.f, location.y.f)
        self.lastTouchedTime = CACurrentMediaTime()
        print("recieved tap at \(location)")
      }
      .store(in: &cancellables)
  }

  func updateTapLocation(_ location: CGPoint) {
    tapLocationSubject.send(location)
  }

  func asGMGameInput() -> GMGameInput {
    .init(touchCoords: touchCoords, lastTouchedTime: lastTouchedTime)
  }
}

struct GMGameInput {
  var touchCoords: F2
  var lastTouchedTime: Double = 0.0
}
