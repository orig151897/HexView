//
//  HexViewApp.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI

@main
struct HexViewApp: App {
    @State private var openFileMenuItemSelected = false

    var body: some Scene {
        WindowGroup {
            ContentView(openFileMenuItemSelected: $openFileMenuItemSelected)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open...") {
                    openFileMenuItemSelected = true
                }
                .keyboardShortcut("O")
            }
        }
    }
}
