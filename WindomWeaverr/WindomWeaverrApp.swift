//
//  WindomWeaverrApp.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

// ekranBolmeApp.swift
import SwiftUI

@main
struct WindowWeaverApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }

    init() {
        // Status bar controller'ı başlat
        _ = StatusBarController.shared
    }
}
