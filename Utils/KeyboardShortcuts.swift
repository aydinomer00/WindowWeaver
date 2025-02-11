//
//  KeyboardShortcuts.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 8.02.2025.
//

import Carbon
import Foundation

class KeyboardShortcuts {
    static let shared = KeyboardShortcuts()
    private let windowManager = WindowManager.shared

    private init() {
        registerGlobalHotKeys()
    }

    private func registerGlobalHotKeys() {
        // Left 2/3 split
        registerHotKey(
            id: 1,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | optionKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.resize(.twoThirds(.left))
        }

        // Right 2/3 split
        registerHotKey(
            id: 2,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | optionKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.resize(.twoThirds(.right))
        }

        // Left 1/3 split
        registerHotKey(
            id: 3,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.resize(.third(.left))
        }

        // Center 1/3 split
        registerHotKey(
            id: 4,
            keyCode: UInt32(kVK_DownArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.resize(.third(.center))
        }

        // Right 1/3 split
        registerHotKey(
            id: 5,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.resize(.third(.right))
        }

        // Left half split
        registerHotKey(
            id: 6,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.resize(.half(.left))
        }

        // Right half split
        registerHotKey(
            id: 7,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.resize(.half(.right))
        }

        // Full screen
        registerHotKey(
            id: 8,
            keyCode: UInt32(kVK_Return),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.resize(.generic(.fullScreen))
        }

        // Center window
        registerHotKey(
            id: 9,
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.resize(.generic(.center))
        }
    }

    private func registerHotKey(id: Int, keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        var hotKeyRef: EventHotKeyRef?

        // Create a unique ID for the hot key
        let hotKeyID = EventHotKeyID(signature: OSType(id), id: UInt32(id))

        // Save the hot key callback
        HotKeyCallbacks.shared.callbacks[id] = action

        // Register the hot key
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        if status != noErr {
            print("Failed to register hot key: \(status)")
        }
    }
}

// HotKeyCallbacks.swift - Helper class to store callbacks
class HotKeyCallbacks {
    static let shared = HotKeyCallbacks()
    var callbacks: [Int: () -> Void] = [:]

    private init() {}
}
