//
//  HexViewTests.swift
//  HexViewTests
//
//  Created by Igor Kolesnik on 24/10/2026.
//

import Testing

@testable import HexView

@MainActor
struct HexViewTests {
    @Test func greatestDivisibleBy() {
        #expect(Things.greatestOf(x: 9, divisibleBy: 2) == 10)
    }

    @Test func smallestDivisibleBy() {
        #expect(Things.smallestOf(x: 9, divisibleBy: 2) == 8)
    }

    @Test func foo() {
        let count = 623

        let a = (count + 15) / 16
        let b = Things.greatestOf(x: count, divisibleBy: 16) / 16
        #expect(a == b)
    }
}
