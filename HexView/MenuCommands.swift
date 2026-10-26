//
//  MenuCommands.swift
//  HexView
//
//  Created by Igor Kolesnik on 26/10/2026.
//

import SwiftUI

struct MenuCommands: Commands {
    @FocusedValue(MenuModel.self) private var menuModel: MenuModel?

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("Open...") {
                menuModel?.fileOpen = true
            }
            .keyboardShortcut("O")
        }
    }
}
