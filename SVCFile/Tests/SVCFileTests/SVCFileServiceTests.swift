import Testing
@testable import SVCFile

import Foundation

@Test func loadJsonFile() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    // Swift Testing Documentation
    // https://developer.apple.com/documentation/testing

  let bundle = Bundle.module
  let service = SVCFileService()

  var count = 0
  service.sync(
    LoadJsonFileCommand(
      fileDescriptor: SVCFileDescriptor(name: "Resources/books", ext: .json),
      decodeType: Books.self,
      bundle: bundle
    ) { (books: Books) in
      count = books.books.count
    }
  )

  #expect(count == 1)
}

struct Books: Decodable {
  let books: [Book]
}

struct Book: Decodable {
  let title: String
  let author: String
}
