//
//  MetalView.swift
//  gamesomesort
//
//  Created by David Kanenwisher on 5/30/25.
//

import SwiftUI
import MetalKit

struct MetalView: View {
  let appCore: AppCore
  @State private var metalView = MTKView()
  @State private var gameController: GameController?

  var body: some View {
    MetalViewRepresentable(metalView: $metalView)
      .onAppear {
        gameController = GameController(
          appCore: appCore,
          metalView: metalView
        )
      }
  }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
  @Binding var metalView: MTKView

  #if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
  #elseif os(iOS)
  func makeUIView(context: Context) -> MTKView {
    metalView
  }
  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
  #endif

  func updateMetalView() {

  }
}

#Preview {
  MetalView(appCore: AppCore.preview())
}
