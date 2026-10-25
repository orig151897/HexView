//
//  HexView.swift
//  HexView
//
//  Created by Igor Kolesnik on 23/10/2026.
//

import AppKit

class HexView: NSView {
    private var model: HexModel

    init(model: HexModel) {
        self.model = model
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        let strings = model.getHexStrings(for: dirtyRect)
        if strings.isEmpty {
            NSEraseRect(bounds)
            return
        }

        var y = CGFloat(
            model.originOfLineUpYAxes(dirtyRect.origin.y + dirtyRect.height)
        )
        for string in strings {
            let attrString = NSAttributedString(
                string: string,
                attributes: [
                    .font: model.viewFont, .foregroundColor: NSColor.textColor,
                ]
            )
            y -= model.cBox.height
            attrString.draw(at: CGPoint(x: 0, y: y))
        }
    }

    override func keyDown(with event: NSEvent) {
        print(event)
    }
}
