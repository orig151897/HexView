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
    var viewHeight: CGFloat = 0
    var viewWidth: CGFloat = 0

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
        charsPerAddress + spaceAfterAddress
            + (bytesPerLine * charsPerByte + (bytesPerLine - 1)) + spaceAfterHex
            + bytesPerLine
    }

    private func readFileContents() throws {
        guard let url = try resolveBookmark() else {
            throw ModelError.missingURL
        }

        fileContents = try Data(contentsOf: url)

        cBox = NSAttributedString(
            string: "F",
            attributes: [.font: viewFont]
        ).boundingRect(with: .zero)

        totalLines =
            Things.greatestOf(x: fileContents!.count, divisibleBy: bytesPerLine)
            / bytesPerLine

        viewWidth = CGFloat(charsPerLine) * cBox.width
        viewHeight = CGFloat(totalLines) * cBox.height
    }

    func originOfLineDownYAxes(_ y: CGFloat) -> Int {
        var yy = Int(y)
        let ch = Int(cBox.height)
        yy = Things.smallestOf(x: yy, divisibleBy: ch)
        return max(yy, 0)
    }

    func originOfLineUpYAxes(_ y: CGFloat) -> Int {
        var yy = Int(y)
        let ch = Int(cBox.height)
        let vh = Int(viewHeight)
        yy = Things.greatestOf(x: yy, divisibleBy: ch)
        return min(yy, vh)
    }

    private func indexOfLineWithOriginAt(y: Int) -> Int {
        let ch = Int(cBox.height)
        return totalLines - (y / ch)
    }

    func getHexStrings(for region: NSRect) -> [String] {
        guard let fileContents else {
            return []
        }

        let bottomLine = indexOfLineWithOriginAt(
            y: originOfLineDownYAxes(region.origin.y)
        )
        let topLine = indexOfLineWithOriginAt(
            y: originOfLineUpYAxes(region.origin.y + region.height)
        )

        let nBytes = max((bottomLine - topLine + 1) * bytesPerLine, 0)

        // "Forms" the half-open range of bytes firstByte..<lastByte
        let firstByte = topLine * bytesPerLine
        let lastByte = min(firstByte + nBytes, fileContents.count)

        var strings: [String] = []

        var offset = firstByte
        while offset < lastByte {
            let nextOffset = offset + bytesPerLine
            let count = nextOffset - offset - max(nextOffset - lastByte, 0)

            strings.append(
                buildLine(offset: offset, count: count, data: fileContents)
            )

            offset = nextOffset
        }

        return strings
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
        let contentH = scrollGeometry?.contentSize.height ?? 0
        let insetsH =
            (scrollGeometry?.contentInsets.top ?? 0)
            + (scrollGeometry?.contentInsets.bottom ?? 0)
        let visibleH = scrollGeometry?.visibleRect.height ?? 0
        let maxOffsetY = contentH + insetsH - visibleH

        let contentW = scrollGeometry?.contentSize.width ?? 0
        let insetsW =
            (scrollGeometry?.contentInsets.leading ?? 0)
            + (scrollGeometry?.contentInsets.trailing ?? 0)
        let visibleW = scrollGeometry?.visibleRect.width ?? 0
        let maxOffsetX = contentW + insetsW - visibleW
        
        var point = position.point ?? scrollGeometry?.contentOffset ?? .zero
        if position.point == nil {
            point.y += insetsH
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
            point.y -= visibleH
        case .pageDown:
            point.y += visibleH
        case .home:
            point.y = 0
        case .end:
            point.y = maxOffsetY
        default:
            return point
        }

        if point.y < 0 {
            point.y = 0
        } else if point.y > maxOffsetY {
            point.y = maxOffsetY
        }

        if point.x < 0 {
            point.x = 0
        } else if point.x > maxOffsetX {
            point.x = maxOffsetX
        }

        return point
    }

    private var scrollGeometry: ScrollGeometry?

    func scrollGeometryChanged(_ geometry: ScrollGeometry) {
        scrollGeometry = geometry
    }
}
