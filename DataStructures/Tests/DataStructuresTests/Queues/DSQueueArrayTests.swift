//
//  DSQueueArrayTests.swift
//  DataStructures
//
//  Created by David Kanenwisher on 2/5/26.
//

import Testing
@testable import DataStructures

struct DSQueueArrayTests {

  @Test func verifyEnqueueDequeueAndPeek() throws {
    var queue = DSQueueArray<String>()
    queue.enqueue("Cid")
    queue.enqueue("Veronica")
    queue.enqueue("Celes")

    #expect(["Cid", "Veronica", "Celes"] == queue.toArray())
    #expect("Cid" == queue.dequeue())
    #expect("Veronica" == queue.peek())
  }
}
