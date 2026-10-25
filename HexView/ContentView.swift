//
//  ContentView.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    private let model = HexModel()
    private let view = HexView()

    @State private var position = ScrollPosition(point: .zero)

    @Binding var openFileMenuItemSelected: Bool

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RepresentedHexView(model: model, view: view)
                .frame(width: model.viewWidth, height: model.viewHeight)
                .padding()
        }
        .defaultScrollAnchor(.topLeading)
        .scrollPosition($position)
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
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.downArrow) {
            position.scrollTo(
                point: model.keyPress(key: .downArrow, position: position)
            )
            return .handled
        }
        .onKeyPress(.upArrow) {
            position.scrollTo(
                point: model.keyPress(key: .upArrow, position: position)
            )
            return .handled
        }
        .onKeyPress(.leftArrow) {
            position.scrollTo(
                point: model.keyPress(key: .leftArrow, position: position)
            )
            return .handled
        }
        .onKeyPress(.rightArrow) {
            position.scrollTo(
                point: model.keyPress(key: .rightArrow, position: position)
            )
            return .handled
        }
        .onKeyPress(.pageDown) {
            position.scrollTo(
                point: model.keyPress(key: .pageDown, position: position)
            )
            return .handled
        }
        .onKeyPress(.pageUp) {
            position.scrollTo(
                point: model.keyPress(key: .pageUp, position: position)
            )
            return .handled
        }
        .onKeyPress(
            .home,
            action: {
                position.scrollTo(
                    point: model.keyPress(key: .home, position: position)
                )
                return .handled
            }
        )
        .onKeyPress(
            .end,
            action: {
                position.scrollTo(
                    point: model.keyPress(key: .end, position: position)
                )
                return .handled
            }
        )
        .onScrollGeometryChange(for: Bool.self) { geometry in
            model.scrollGeometryChanged(geometry)
            return false
        } action: { oldValue, newValue in
        }
        .animation(.default, value: position)
    }
}

#Preview {
    ContentView(openFileMenuItemSelected: Binding.constant(false))
}
