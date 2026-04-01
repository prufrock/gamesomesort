//
//  AppCoreConfigExts.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 3/31/26.
//

import SVCFile

extension AppCoreConfig.Services.FileService.FileDescriptor {
  var svcFileDescriptor: SVCFileDescriptor {
    .init(
      name: self.name,
      ext: self.ext.svcFileType
    )
  }
}

extension AppCoreConfig.Services.FileService.FileType {
  var svcFileType: SVCFileType {
    .init(
      rawValue: self.rawValue
    )!
  }
}
