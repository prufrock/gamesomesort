//
//  ContentView.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/29/25.
//

import SwiftUI

struct ContentView: View {
  let appCore: AppCore
  var body: some View {
    VStack {
      MetalView(appCore: appCore)
    }
    .padding()
  }
}

#Preview {
  ContentView(
    appCore: AppCore.preview()
  )
}
