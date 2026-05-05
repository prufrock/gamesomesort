//
//  SVCServiceFile.swift
//  SVCFile
//
//  Created by David Kanenwisher on 3/30/26.
//

import Foundation
import SVCDefinitions

public class SVCFileService {

  public init() {}

  public func sync<T: Decodable>(_ command: LoadJsonFileCommand<T>) {
    command.execute(fileService: self)
  }
}

public enum SVCFileSource {
  case bundle(Bundle)
  case filePath(URL)

  func resolve(_ descriptor: SVCFileDescriptor) -> URL {
    switch self {
    case .bundle(let bundle):
      return bundle.url(
        forResource: descriptor.name,
        withExtension: descriptor.ext.rawValue
      )!
    case .filePath(let baseUrl):
      return baseUrl.appendingPathComponent(descriptor.name)
        .appendingPathExtension(descriptor.ext.rawValue)
    }
  }
}

public struct LoadJsonFileCommand<T: Decodable>: SVCDServiceCommand {
  let fileDescriptor: SVCFileDescriptor
  let decodeType: T.Type
  let source: SVCFileSource
  let block: (T) -> Void

  public init(
    fileDescriptor: SVCFileDescriptor,
    decodeType: T.Type,
    bundle: Bundle = .main,
    block: @escaping (T) -> Void
  ) {
    self.fileDescriptor = fileDescriptor
    self.decodeType = decodeType
    self.source = .bundle(bundle)
    self.block = block
  }

  public init(
    fileDescriptor: SVCFileDescriptor,
    decodeType: T.Type,
    filePath: URL,
    block: @escaping (T) -> Void
  ) {
    self.fileDescriptor = fileDescriptor
    self.decodeType = decodeType
    self.source = .filePath(filePath)
    self.block = block
  }

  func execute(fileService: SVCFileService) {
    let jsonUrl = source.resolve(fileDescriptor)

    let data: Data = try! Data(contentsOf: jsonUrl)
    let jsonData = try! JSONDecoder().decode(decodeType, from: data)
    block(jsonData)
  }
}
