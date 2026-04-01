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

public struct LoadJsonFileCommand<T: Decodable>: SVCDServiceCommand {
  let fileDescriptor: SVCFileDescriptor
  let decodeType: T.Type
  let bundle: Bundle
  let block: (T) -> Void

  public init(
    fileDescriptor: SVCFileDescriptor,
    decodeType: T.Type,
    bundle: Bundle = .main,
    block: @escaping (T) -> Void
  ) {
    self.fileDescriptor = fileDescriptor
    self.decodeType = decodeType
    self.bundle = bundle
    self.block = block
  }

  func execute(fileService: SVCFileService) {
    let jsonUrl = bundle.url(
      forResource: fileDescriptor.name,
      withExtension: fileDescriptor.ext.rawValue
    )!

    let data: Data = try! Data(contentsOf: jsonUrl)
    let jsonData = try! JSONDecoder().decode(decodeType, from: data)
    block(jsonData)
  }
}
