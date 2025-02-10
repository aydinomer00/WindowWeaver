//
//  KeyboardShortcuts.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 8.02.2025.
//

import Foundation
import Carbon

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
            self?.windowManager.divideScreenIntoTwoThirds(position: .left)
        }
        
        // Right 2/3 split
        registerHotKey(
            id: 2,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | optionKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoTwoThirds(position: .right)
        }
        
        // Left 1/3 split
        registerHotKey(
            id: 3,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .left)
        }
        
        // Center 1/3 split
        registerHotKey(
            id: 4,
            keyCode: UInt32(kVK_DownArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .center)
        }
        
        // Right 1/3 split
        registerHotKey(
            id: 5,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .right)
        }
        
        // Left half split
        registerHotKey(
            id: 6,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.divideScreenInHalf(position: .left)
        }
        
        // Right half split
        registerHotKey(
            id: 7,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.divideScreenInHalf(position: .right)
        }
        
        // Full screen
        registerHotKey(
            id: 8,
            keyCode: UInt32(kVK_Return),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.makeFullScreen()
        }
        
        // Center window
        registerHotKey(
            id: 9,
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.centerWindow()
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

// AppDelegate.swift - Install an event handler
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Install the event handler
        installEventHandler()
        
        // Initialize keyboard shortcuts
        _ = KeyboardShortcuts.shared
    }
    
    private func installEventHandler() {
        // Define the event type for hot key pressed events
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        // Install the event handler
        InstallEventHandler(
            GetEventDispatcherTarget(),
            { (_, event, _) -> OSStatus in
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                
                if status == noErr {
                    if let callback = HotKeyCallbacks.shared.callbacks[Int(hotKeyID.id)] {
                        DispatchQueue.main.async {
                            callback()
                        }
                    }
                }
                
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )
    }
}
