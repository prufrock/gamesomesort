//
//  CTSQueueArrayTests.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 6/27/25.
//

import Testing
@testable import gamesomesort

struct CTSQueueArrayTests {

  @Test func verifyEnqueueDequeueAndPeek() throws {
    var queue = CTSQueueArray<String>()
    queue.enqueue("Cid")
    queue.enqueue("Veronica")
    queue.enqueue("Celes")

    #expect(["Cid", "Veronica", "Celes"] == queue.toArray())
    #expect("Cid" == queue.dequeue())
    #expect("Veronica" == queue.peek())
  }
}
