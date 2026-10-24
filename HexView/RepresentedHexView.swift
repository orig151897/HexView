//
//  RepresentedHexView.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI

struct RepresentedHexView: NSViewRepresentable {
    let model: HexModel
    let view: HexView

    typealias NSViewType = HexView

    func makeNSView(context: Context) -> NSViewType {
        view.model = model
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {
        print("updateNSView")
    }
}
