//
//  Helpers.swift
//  HexView
//
//  Created by Igor Kolesnik on 23/10/2026.
//

import Foundation

@MainActor
enum Things {
    static func greatestOf(x: Int, divisibleBy y: Int) -> Int {
        let xx = Double(x)
        let yy = Double(y)
        let qq = (xx / yy).rounded(.awayFromZero)
        return Int(qq) * y
    }

    static func smallestOf(x: Int, divisibleBy y: Int) -> Int {
        (x / y) * y
    }
}
