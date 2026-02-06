//
//  ControllerInput.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/19/25.
//

import DataStructures
import Foundation
import Combine
import MetalKit

class ControllerInput {
  let config: AppCoreConfig

  private var tapLocationSubject: PassthroughSubject<CGPoint, Never> = PassthroughSubject<CGPoint, Never>()
  private var tapLocationCancelable: AnyCancellable?

  private var updateFrameSizeSubject: PassthroughSubject<CGSize, Never> = PassthroughSubject()
  private var updateFrameSizeCancelable: AnyCancellable?

  private var events: any DSQueue<GMGameInput.Events> = DSQueueArray<GMGameInput.Events>()

  init(config: AppCoreConfig) {
    self.config = config
    setupTapLocationSubscribers()
    setupUpdateFrameSizeSubscribers()
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
          _ = self.events.enqueue(.tap(tapLocation: F2(location.x.f, location.y.f), lastTapTime: CACurrentMediaTime()))
        }
      )
  }

  private func setupUpdateFrameSizeSubscribers() {
    if updateFrameSizeCancelable != nil {
      return
    }

    updateFrameSizeCancelable =
      updateFrameSizeSubject
      .sink(
        receiveCompletion: { completion in
          fatalError(
            "ControllerInput::updateFrameSizeSubject received completion: \(completion)."
              + "You left this here, so you would know when the subscription dies."
              + "A likely fix might be to either nil the cancellable or store in a set of cancellables."
              + "Either way you need to make sure the subscription is started again."
          )
        },
        receiveValue: { [weak self] size in
          guard let self else { return }
          _ = self.events.enqueue(.screenSizeChanged(size: size))
        }
      )
  }

  func updateTapLocation(_ location: CGPoint) {
    tapLocationSubject.send(location)
  }

  func updateFrameSize(_ size: CGSize) {
    updateFrameSizeSubject.send(size)
  }

  func update() -> GMGameInput {
    defer {
      events = DSQueueArray<GMGameInput.Events>()
    }

    return GMGameInput(events: events)
  }
}

struct GMGameInput {
  let events: any DSQueue<Events>

  enum Events {
    case tap(tapLocation: F2, lastTapTime: Double)
    case screenSizeChanged(size: CGSize)
  }
}

extension GMGameInput {
  init() {
    events = DSQueueArray<Events>()
  }
}
