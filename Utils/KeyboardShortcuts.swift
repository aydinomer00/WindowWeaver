//
//  KeyboardShortcuts.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 8.02.2025.
//

// KeyboardShortcuts.swift
import Foundation
import Carbon

class KeyboardShortcuts {
    static let shared = KeyboardShortcuts()
    private let windowManager = WindowManager.shared
    
    private init() {
        registerGlobalHotKeys()
    }
    
    private func registerGlobalHotKeys() {
        // Sol 2/3
        registerHotKey(
            id: 1,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | optionKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoTwoThirds(position: .left)
        }
        
        // Sağ 2/3
        registerHotKey(
            id: 2,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | optionKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoTwoThirds(position: .right)
        }
        
        // Sol 1/3
        registerHotKey(
            id: 3,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .left)
        }
        
        // Orta 1/3
        registerHotKey(
            id: 4,
            keyCode: UInt32(kVK_DownArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .center)
        }
        
        // Sağ 1/3
        registerHotKey(
            id: 5,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowManager.divideScreenIntoThirds(position: .right)
        }
        
        // Sol Yarım
        registerHotKey(
            id: 6,
            keyCode: UInt32(kVK_LeftArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.divideScreenInHalf(position: .left)
        }
        
        // Sağ Yarım
        registerHotKey(
            id: 7,
            keyCode: UInt32(kVK_RightArrow),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.divideScreenInHalf(position: .right)
        }
        
        // Tam Ekran
        registerHotKey(
            id: 8,
            keyCode: UInt32(kVK_Return),
            modifiers: UInt32(cmdKey | controlKey)
        ) { [weak self] in
            self?.windowManager.makeFullScreen()
        }
        
        // Merkez
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
        
        // Kısayol için benzersiz ID oluştur
        let hotKeyID = EventHotKeyID(signature: OSType(id), id: UInt32(id))
        
        // Kısayol callback'ini sakla
        HotKeyCallbacks.shared.callbacks[id] = action
        
        // Kısayolu kaydet
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
        
        if status != noErr {
            print("Kısayol kaydedilemedi: \(status)")
        }
    }
}

// HotKeyCallbacks.swift - Callback'leri saklamak için yardımcı sınıf
class HotKeyCallbacks {
    static let shared = HotKeyCallbacks()
    var callbacks: [Int: () -> Void] = [:]
    
    private init() {}
}

// AppDelegate.swift - Event handler eklemeliyiz
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Event handler'ı kaydet
        installEventHandler()
        
        // Kısayolları başlat
        _ = KeyboardShortcuts.shared
    }
    
    private func installEventHandler() {
        // Event tiplerimizi tanımla
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        
        // Event handler'ı kaydet
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
