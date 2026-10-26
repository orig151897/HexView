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

    @State private var menuModel = MenuModel()
    @State private var scrollWhere = ScrollPosition(point: .zero)

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RepresentedHexView(model: model)
                .frame(width: model.contentWidth, height: model.contentHeight)
                .padding([.leading, .trailing, .bottom])
        }
        .defaultScrollAnchor(.topLeading)
        .scrollPosition($scrollWhere)
        .focusedSceneValue(menuModel)
        .fileImporter(
            isPresented: $menuModel.fileOpen,
            allowedContentTypes: [.data]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    try model.openURL(url)
                    NSApplication.shared.mainWindow?.setTitleWithRepresentedFilename(url.path(percentEncoded: false))
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
        // The sole purpose of this is to track SwiftUI's scrolling
        // position changes which happen when the user scrolls with mouse.
        .onScrollGeometryChange(for: Bool.self) { geometry in
            model.scrollGeometryChanged(geometry)
            return false
        } action: { _, _ in
        }
    }
}

#Preview {
    ContentView()
}
