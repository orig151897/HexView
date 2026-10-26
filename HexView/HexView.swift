//
//  HexView.swift
//  HexView
//
//  Created by Igor Kolesnik on 23/10/2026.
//

import AppKit
import os

class HexView: NSView {
    private var model: HexModel

    init(model: HexModel) {
        self.model = model
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        logger.critical("init(coder:) has not been implemented")
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let lines = model.getHexLines(for: dirtyRect)
        if lines.isEmpty {
            NSEraseRect(bounds)
            return
        }

        var y = CGFloat(
            model.originOfLineUpYAxes(dirtyRect.origin.y + dirtyRect.height)
        )
        for line in lines {
            y -= model.cBox.height
            line.draw(at: CGPoint(x: 0, y: y))
        }
    }
}
