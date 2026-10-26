//
//  HexModel.swift
//  HexView
//
//  Created by Igor Kolesnik on 23/10/2026.
//

import AppKit
import SwiftUI

enum ModelError: Error {
    case resourceAccess
    case missingURL
}

class HexModel {
    private var bookmark: Data?
    private var fileContents: Data?

    private var totalLines = 0

    private let bytesPerLine = 16
    private let charsPerAddress = 8
    private let charsPerByte = 2
    private let spaceAfterAddress = 3
    private let spaceAfterHex = 3

    var cBox = NSRect.zero
    var viewFont = NSFont.monospacedSystemFont(
        ofSize: NSFont.systemFontSize,
        weight: .regular
    )
    var contentHeight: CGFloat = 0
    var contentWidth: CGFloat = 0

    private var scrollGeometry: ScrollGeometry?

    func openURL(_ url: URL) throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw ModelError.resourceAccess
        }

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        bookmark = try url.bookmarkData(options: .withSecurityScope)

        try readFileContents()
    }

    private func readFileContents() throws {
        guard let url = try resolveBookmark() else {
            throw ModelError.missingURL
        }

        fileContents = try Data(contentsOf: url)

        cBox = NSAttributedString(
            string: "F",
            attributes: [.font: viewFont]
        )
        .boundingRect(with: .zero)

        totalLines = Things.greatestOf(
            x: fileContents!.count,
            divisibleBy: bytesPerLine
        )
        / bytesPerLine

        contentWidth = CGFloat(charsPerLine) * cBox.width
        contentHeight = CGFloat(totalLines) * cBox.height
    }

    private func resolveBookmark() throws -> URL? {
        if bookmark == nil {
            return nil
        }

        var isStale = false
        let url = try URL(
            resolvingBookmarkData: bookmark!,
            options: .withSecurityScope,
            relativeTo: nil,
            bookmarkDataIsStale: &isStale
        )
        if isStale {
            bookmark = try url.bookmarkData(options: .withSecurityScope)
        }
        return url
    }

    private var charsPerLine: Int {
        charsPerAddress
            + spaceAfterAddress
            + (bytesPerLine * charsPerByte + (bytesPerLine - 1))
            + spaceAfterHex
            + bytesPerLine
    }

    func getHexLines(for region: NSRect) -> [NSAttributedString] {
        guard let fileContents else {
            return []
        }

        // The region may contain nonvisible area. Make sure we
        // get indices that represent the real file's data.
        let bottomLine = min(
            indexOfLineWithOriginAt(y: originOfLineDownYAxes(region.origin.y)),
            totalLines - 1
        )
        let topLine = indexOfLineWithOriginAt(
            y: originOfLineUpYAxes(region.origin.y + region.height)
        )
        if bottomLine < topLine {
            return []
        }

        var lines: [NSAttributedString] = []
        for i in topLine...bottomLine {
            if let line = getLine(i, fileContents) {
                lines.append(line)
            }
        }
        return lines
    }

    private func indexOfLineWithOriginAt(y: Int) -> Int {
        let ch = Int(cBox.height)
        return totalLines - (y / ch)
    }

    func originOfLineUpYAxes(_ y: CGFloat) -> Int {
        var yy = Int(y)
        let ch = Int(cBox.height)
        let vh = Int(contentHeight)
        yy = Things.greatestOf(x: yy, divisibleBy: ch)
        return min(yy, vh)
    }

    private func originOfLineDownYAxes(_ y: CGFloat) -> Int {
        var yy = Int(y)
        let ch = Int(cBox.height)
        yy = Things.smallestOf(x: yy, divisibleBy: ch)
        return max(yy, 0)
    }

    private func getLine(_ index: Int, _ data: Data) -> NSAttributedString? {
        let offset = index * bytesPerLine
        let count = min(bytesPerLine, data.count - offset)

        let line = buildLine(offset: offset, count: count, data: data)

        let attrLine = NSAttributedString(
            string: line,
            attributes: [
                .font: viewFont, .foregroundColor: NSColor.textColor,
            ]
        )
        return attrLine
    }

    private func buildLine(offset: Int, count: Int, data: Data) -> String {
        var line = String(format: "%08X", offset)
        line += String(repeating: " ", count: spaceAfterAddress - 1)
        var ascii: [Character] = []
        for i in offset..<(offset + count) {
            let byte = data[i]
            ascii.append(charFrom(byte: byte))
            line += String(format: " %@", hexViewOf(byte: byte))
        }
        if count < bytesPerLine {
            line += String(repeating: " ", count: (bytesPerLine - count) * 3)
        }
        line += String(repeating: " ", count: spaceAfterHex)
        line += ascii
        return line
    }

    private func hexViewOf(byte: UInt8) -> String {
        let hexDigits: [Character] = [
            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C",
            "D",
            "E", "F",
        ]
        let loNibble = Int(byte & 0x0f)
        let hiNibble = Int((byte >> 4) & 0x0f)
        return "\(hexDigits[hiNibble])\(hexDigits[loNibble])"
    }

    private func charFrom(byte: UInt8) -> Character {
        (byte > 31 && byte < 128) ? Character(UnicodeScalar(byte)) : "."
    }

    func keyPress(
        key: KeyEquivalent,
        position: ScrollPosition
    ) -> CGPoint {
        var contentSize = CGSize.zero
        var contentInsets = EdgeInsets()
        var visibleRect = CGRect.zero
        var containerSize = CGSize.zero

        if let scrollGeometry {
            contentSize = scrollGeometry.contentSize
            contentInsets = scrollGeometry.contentInsets
            visibleRect = scrollGeometry.visibleRect
            containerSize = scrollGeometry.containerSize
        }

        let maxOffsetX =
            contentSize.width + contentInsets.leading + contentInsets.trailing
            - visibleRect.width
        let maxOffsetY =
            contentSize.height + contentInsets.top + contentInsets.bottom
            - visibleRect.height

        var point = position.point ?? scrollGeometry?.contentOffset ?? .zero
        if position.point == nil {
            point.x += contentInsets.leading + contentInsets.trailing
            point.y += contentInsets.top + contentInsets.bottom
        }

        switch key {
        case .upArrow:
            point.y -= cBox.height
        case .downArrow:
            point.y += cBox.height
        case .leftArrow:
            point.x -= cBox.width
        case .rightArrow:
            point.x += cBox.width
        case .pageUp:
            point.y -= CGFloat(
                Things.smallestOf(
                    x: Int(containerSize.height),
                    divisibleBy: Int(cBox.height)
                )
            )
        case .pageDown:
            point.y += CGFloat(
                Things.smallestOf(
                    x: Int(containerSize.height),
                    divisibleBy: Int(cBox.height)
                )
            )
        case .home:
            point.y = 0
        case .end:
            point.y = maxOffsetY
        default:
            return point
        }

        if point.x < 0 {
            point.x = 0
        } else if point.x > maxOffsetX {
            point.x = maxOffsetX
        }
        if point.y < 0 {
            point.y = 0
        } else if point.y > maxOffsetY {
            point.y = maxOffsetY
        }
        return point
    }

    func scrollGeometryChanged(_ geometry: ScrollGeometry) {
        scrollGeometry = geometry
    }
}
