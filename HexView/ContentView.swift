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

    @State private var scrollWhere = ScrollPosition(point: .zero)

    @Binding var openFileMenuItemSelected: Bool

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RepresentedHexView(model: model)
                .frame(width: model.viewWidth, height: model.viewHeight)
                .padding()
        }
        .defaultScrollAnchor(.topLeading)
        .scrollPosition($scrollWhere)
        .fileImporter(
            isPresented: $openFileMenuItemSelected,
            allowedContentTypes: [.data]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    try model.openURL(url)
                    // Reset the scroll position after a new file is loaded.
                    scrollWhere = ScrollPosition(point: .zero)
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
            scrollWhere.scrollTo(
                point: model.keyPress(key: .downArrow, position: scrollWhere)
            )
            return .handled
        }
        .onKeyPress(.upArrow) {
            scrollWhere.scrollTo(
                point: model.keyPress(key: .upArrow, position: scrollWhere)
            )
            return .handled
        }
        .onKeyPress(.leftArrow) {
            scrollWhere.scrollTo(
                point: model.keyPress(key: .leftArrow, position: scrollWhere)
            )
            return .handled
        }
        .onKeyPress(.rightArrow) {
            scrollWhere.scrollTo(
                point: model.keyPress(
                    key: .rightArrow,
                    position: scrollWhere
                )
            )
            return .handled
        }
        .onKeyPress(.pageDown) {
            scrollWhere.scrollTo(
                point: model.keyPress(key: .pageDown, position: scrollWhere)
            )
            return .handled
        }
        .onKeyPress(.pageUp) {
            scrollWhere.scrollTo(
                point: model.keyPress(key: .pageUp, position: scrollWhere)
            )
            return .handled
        }
        .onKeyPress(
            .home,
            action: {
                scrollWhere.scrollTo(
                    point: model.keyPress(key: .home, position: scrollWhere)
                )
                return .handled
            }
        )
        .onKeyPress(
            .end,
            action: {
                scrollWhere.scrollTo(
                    point: model.keyPress(key: .end, position: scrollWhere)
                )
                return .handled
            }
        )
        .onScrollGeometryChange(for: Bool.self) { geometry in
            model.scrollGeometryChanged(geometry)
            return false
        } action: { oldValue, newValue in
        }
        // .animation(.default, value: position)
    }
}

#Preview {
    ContentView(openFileMenuItemSelected: Binding.constant(false))
}
