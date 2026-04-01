//
//  SVCFileDescriptor.swift
//  SVCFile
//
//  Created by David Kanenwisher on 3/30/26.
//

public struct SVCFileDescriptor {
  public let name: String
  public let ext: SVCFileType

  public init(name: String, ext: SVCFileType) {
    self.name = name
    self.ext = ext
  }
}

public enum SVCFileType: String, CaseIterable {
  case json = "json"
}
