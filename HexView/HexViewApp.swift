//
//  HexViewApp.swift
//  HexView
//
//  Created by Igor Kolesnik on 22/10/2026.
//

import SwiftUI

@main
struct HexViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            MenuCommands()
        }
    }
}
