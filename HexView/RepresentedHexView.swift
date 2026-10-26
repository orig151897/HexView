//
//  RepresentedHexView.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI

struct RepresentedHexView: NSViewRepresentable {
    let model: HexModel

    typealias NSViewType = HexView

    func makeNSView(context: Context) -> NSViewType {
        HexView(model: model)
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}
