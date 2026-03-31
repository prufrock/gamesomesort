//
//  SVCServiceFile.swift
//  SVCFile
//
//  Created by David Kanenwisher on 3/30/26.
//

import Foundation
import SVCDefinitions

class SVCFileService {
  func sync(_ command: LoadJsonFileCommand) {
    command.execute(fileService: self)
  }
}

struct LoadJsonFileCommand: SVCDServiceCommand {
  let fileDescriptor: SVCFileDescriptor
  let bundle: Bundle
  let block: (Data) -> Void

  init(
    fileDescriptor: SVCFileDescriptor,
    bundle: Bundle = .main,
    block: @escaping (Data) -> Void
  ) {
    self.fileDescriptor = fileDescriptor
    self.bundle = bundle
    self.block = block
  }

  func execute(fileService: SVCFileService) {
    let jsonUrl = bundle.url(
      forResource: fileDescriptor.name,
      withExtension: fileDescriptor.ext.rawValue
    )!

    let jsonData: Data = try! Data(contentsOf: jsonUrl)
    block(jsonData)
  }
}
