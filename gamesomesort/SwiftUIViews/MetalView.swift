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
  @State private var gameController: ControllerGame?

  var body: some View {
    ZStack {
      MetalViewRepresentable(metalView: $metalView)
        .onAppear {
          if gameController == nil {
            initGameController()
          }
        }
    }.onTapGesture { location in
      gameController?.updateTapLocation(location)
    }
  }

  func initGameController() {
    gameController = appCore.createControllerGame(view: metalView)
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
