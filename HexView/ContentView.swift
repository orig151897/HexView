//
//  ContentView.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var model = HexModel()
    private let view = HexView()

    @Binding var openFileMenuItemSelected: Bool

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RepresentedHexView(model: model, view: view)
                .frame(width: model.viewWidth, height: model.viewHeight)
                .padding()
        }
        .defaultScrollAnchor(.topLeading)
        .fileImporter(
            isPresented: $openFileMenuItemSelected,
            allowedContentTypes: [.data]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    try model.openURL(url)
                    view.needsDisplay = true
                } catch {
                    print("HexView: \(error)")
                }

            case .failure(let error):
                print(error)
            }
        }
    }
}

#Preview {
    ContentView(openFileMenuItemSelected: Binding.constant(false))
}
