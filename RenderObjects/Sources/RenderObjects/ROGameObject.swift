//
//  ROGameObject.swift
//  RenderObjects
//
//  Created by David Kanenwisher on 10/4/26.
//

import VRTMath

public struct ROGameObject {
  public let color: F3
  public let model: String
  public let name: String
  public let transform: ROTransform

  public init(color: F3, model: String, name: String, transform: ROTransform) {
    self.color = color
    self.model = model
    self.name = name
    self.transform = transform
  }
}
