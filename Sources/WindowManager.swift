//
//  WindowManager.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

import Cocoa
import Carbon
import ApplicationServices

let kAXFrameAttribute: CFString = "AXFrame" as CFString
let kAXSizeAttribute: CFString = "AXSize" as CFString
let kAXPositionAttribute: CFString = "AXPosition" as CFString

class WindowManager: ObservableObject {
    static let shared = WindowManager()
    private var selectedApp: NSRunningApplication?
    private var activeWindow: AXUIElement?
    
    private init() {
        checkAccessibilityPermissions()
    }
    
    func resize(_ screenPosition: ScreenPosition) {
        switch screenPosition {
        case let .corner(corner):
            moveToCorner(position: corner)
        case let .half(half):
            divideScreenInHalf(position: half)
        case let .third(third):
            divideScreenIntoThirds(position: third)
        case let .twoThirds(twoThirds):
            divideScreenIntoTwoThirds(position: twoThirds)
        case let .vertical(vertical):
            divideScreenVertically(position: vertical)
        case let .generic(generic):
            switch generic {
            case .center:
                centerWindow()
            case .fullScreen:
                makeFullScreen()
            }
        }
    }
    
    func repositionWindowUsingAppleScript(for app: NSRunningApplication, position: ScreenPosition.Third) {
        guard let appName = app.localizedName, let screen = NSScreen.main else {
            print("Could not obtain the application name or the main screen.")
            return
        }
        
        let screenFrame = screen.frame
        let thirdWidth = screenFrame.width / 3
        let newX: CGFloat
        switch position {
        case .left:
            newX = screenFrame.minX
        case .center:
            newX = screenFrame.minX + thirdWidth
        case .right:
            newX = screenFrame.minX + (thirdWidth * 2)
        }
        
        let newFrame = NSRect(x: newX, y: screenFrame.minY, width: thirdWidth, height: screenFrame.height)
        
        let script = """
        tell application "\(appName)"
            try
                set bounds of front window to {\(Int(newFrame.origin.x)), \(Int(newFrame.origin.y)), \(Int(newFrame.origin.x + newFrame.size.width)), \(Int(newFrame.origin.y + newFrame.size.height))}
            on error errMsg
                return errMsg
            end try
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            } else {
                print("\(appName)'s window moved to \(newFrame). Result: \(result.stringValue ?? "Success")")
            }
        }
    }
    
    func repositionAllWindowsIntoThirds(position: ScreenPosition.Third) {
        let apps = NSWorkspace.shared.runningApplications.filter { app in
            app.activationPolicy == .regular && app.bundleIdentifier != Bundle.main.bundleIdentifier
        }
        
        for app in apps {
            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            var windowListRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(appElement, "AXWindows" as CFString, &windowListRef)
            
            if result == .success, let windows = windowListRef as? [AXUIElement] {
                for window in windows {
                    var frameValue: CFTypeRef?
                    if AXUIElementCopyAttributeValue(window, kAXFrameAttribute, &frameValue) == .success,
                       let frame = frameValue as? CGRect {
                        
                        // Determine which screen the window is on
                        let windowScreen = NSScreen.screens.first { $0.frame.intersects(frame) } ?? NSScreen.main!
                        let screenFrame = windowScreen.frame
                        
                        // Calculate the window frame for a third of the screen (e.g., for the right third)
                        let thirdWidth = screenFrame.width / 3
                        let newX: CGFloat
                        switch position {
                        case .left:
                            newX = screenFrame.minX
                        case .center:
                            newX = screenFrame.minX + thirdWidth
                        case .right:
                            newX = screenFrame.minX + (thirdWidth * 2)
                        }
                        
                        let newFrame = NSRect(x: newX,
                                              y: screenFrame.minY,
                                              width: thirdWidth,
                                              height: screenFrame.height)
                        
                        // Move the window to the new position
                        let newPos = AXValue.from(value: newFrame.origin, type: .cgPoint)
                        let newSize = AXValue.from(value: newFrame.size, type: .cgSize)
                        AXUIElementSetAttributeValue(window, kAXPositionAttribute, newPos)
                        AXUIElementSetAttributeValue(window, kAXSizeAttribute, newSize)
                        
                        print("\(app.localizedName ?? "Unknown")'s window moved to \(newFrame).")
                    } else {
                        print("Could not retrieve the frame for \(app.localizedName ?? "Unknown")'s window.")
                    }
                }
            } else {
                print("Could not retrieve the window list for \(app.localizedName ?? "Unknown").")
            }
        }
    }
    
    func repositionTextEditWindowToRightThird() {
        guard let screen = NSScreen.main else {
            print("Main screen not found.")
            return
        }
        let screenFrame = screen.frame
        let thirdWidth = screenFrame.width / 3
        let newX = screenFrame.minX + (thirdWidth * 2)
        let newFrame = NSRect(x: newX,
                              y: screenFrame.minY,
                              width: thirdWidth,
                              height: screenFrame.height)
        
        let script = """
        tell application "TextEdit"
            try
                set bounds of front window to {\(Int(newFrame.origin.x)), \(Int(newFrame.origin.y)), \(Int(newFrame.origin.x + newFrame.size.width)), \(Int(newFrame.origin.y + newFrame.size.height))}
            on error errMsg
                return errMsg
            end try
        end tell
        """
        
        if let appleScript = NSAppleScript(source: script) {
            var error: NSDictionary?
            let result = appleScript.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            } else {
                print("TextEdit window moved to \(newFrame). Result: \(result.stringValue ?? "Success")")
            }
        }
    }
    
    func divideScreenIntoTwoThirds(position: ScreenPosition.TwoThirds) {
        selectWindow {
            guard let screen = self.currentScreen() else { return }
            let screenFrame = screen.frame
            
            let twoThirdsWidth = (screenFrame.width / 3) * 2
            let x: CGFloat
            
            switch position {
            case .left:
                x = screenFrame.minX
            case .right:
                x = screenFrame.minX + (screenFrame.width / 3)
            }
            
            let frame = NSRect(x: x,
                               y: screenFrame.minY,
                               width: twoThirdsWidth,
                               height: screenFrame.height)
            
            self.moveActiveWindow(to: frame)
        }
    }
    
    func selectWindow(completion: @escaping () -> Void) {
        // Get the frontmost application in the system
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           frontmostApp.bundleIdentifier != Bundle.main.bundleIdentifier {
            // If the active application is not our own, target it
            self.selectedApp = frontmostApp
            frontmostApp.activate(options: .activateIgnoringOtherApps)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateActiveWindow()
                completion()
            }
        } else if let _ = self.selectedApp {
            // If our application is frontmost (e.g., when clicked from the status bar),
            // continue using the previously selected window.
            DispatchQueue.main.async {
                self.updateActiveWindow()
                completion()
            }
        } else {
            // If no valid window is found, show a fallback window selection dialog.
            let apps = NSWorkspace.shared.runningApplications.filter {
                $0.activationPolicy == .regular && $0.bundleIdentifier != Bundle.main.bundleIdentifier
            }
            
            let alert = NSAlert()
            alert.messageText = "Select a Window"
            alert.informativeText = "Please select the window to operate on."
            for (index, app) in apps.enumerated() {
                if let name = app.localizedName {
                    alert.addButton(withTitle: "\(index): \(name)")
                }
            }
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response != .cancel {
                let index = response.rawValue - 1000
                if index < apps.count {
                    self.selectedApp = apps[index]
                    self.selectedApp?.activate(options: .activateIgnoringOtherApps)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.updateActiveWindow()
                        completion()
                    }
                }
            }
        }
    }
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        guard !accessEnabled else { return }
        
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "This application needs accessibility permission to work properly. Please grant permission in System Settings > Privacy & Security > Accessibility."
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func isAccessibilityEnabled() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    private func updateActiveWindow() {
        if !AXIsProcessTrusted() {
            print("[DEBUG] Accessibility permission not granted, requesting permission...")
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
            if !accessEnabled {
                print("[DEBUG] Accessibility permission denied.")
                return
            }
        }
        
        guard let app = selectedApp else {
            print("[DEBUG] updateActiveWindow: selectedApp is nil.")
            return
        }
        print("[DEBUG] updateActiveWindow: Selected app: \(app.localizedName ?? "Unknown") (PID: \(app.processIdentifier))")
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        
        var window: CFTypeRef?
        // First, try the focused window (AXFocusedWindow)
        let resultFocused = AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &window)
        print("[DEBUG] AXFocusedWindow result: \(resultFocused.rawValue)")
        
        // If AXFocusedWindow fails, try the main window (AXMainWindow)
        if resultFocused != .success || window == nil {
            print("[DEBUG] Focused window not obtained, trying AXMainWindow.")
            let resultMain = AXUIElementCopyAttributeValue(appRef, "AXMainWindow" as CFString, &window)
            print("[DEBUG] AXMainWindow result: \(resultMain.rawValue)")
        }
        
        // If still no window is obtained, try selecting the first window from AXWindows
        if window == nil {
            print("[DEBUG] Neither focused nor main window obtained, trying AXWindows.")
            var windowList: CFTypeRef?
            let resultWindows = AXUIElementCopyAttributeValue(appRef, "AXWindows" as CFString, &windowList)
            print("[DEBUG] AXWindows result: \(resultWindows.rawValue)")
            if resultWindows == .success, let windows = windowList as? [AXUIElement], !windows.isEmpty {
                print("[DEBUG] Found \(windows.count) windows, selecting the first one.")
                window = windows[0]
            } else {
                print("[DEBUG] AXWindows value not obtained or empty.")
            }
        }
        
        if let window = window {
            activeWindow = window as! AXUIElement
            print("[DEBUG] activeWindow updated.")
            var frameValue: CFTypeRef?
            let resultFrame = AXUIElementCopyAttributeValue(activeWindow!, kAXFrameAttribute as CFString, &frameValue)
            print("[DEBUG] AXFrame result: \(resultFrame.rawValue)")
            if resultFrame == .success, let frame = frameValue as? CGRect {
                print("[DEBUG] Updated window frame: \(frame)")
            } else {
                print("[DEBUG] Could not obtain window frame.")
            }
        } else {
            print("[DEBUG] updateActiveWindow: Could not obtain window information.")
        }
    }
    
    private func moveActiveWindow(to frame: NSRect) {
        guard let window = activeWindow else {
            print("[DEBUG] moveActiveWindow: activeWindow is nil, cannot move window.")
            return
        }
        print("[DEBUG] Window will be moved to frame: \(frame)")
        let point = AXValue.from(value: frame.origin, type: .cgPoint)
        let size = AXValue.from(value: frame.size, type: .cgSize)
        
        let resultPos = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, point)
        print("[DEBUG] Position set result: \(resultPos)")
        let resultSize = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size)
        print("[DEBUG] Size set result: \(resultSize)")
    }
    
    func moveWindow(to frame: NSRect) {
        if !isAccessibilityEnabled() {
            checkAccessibilityPermissions()
            return
        }
        
        if activeWindow == nil {
            selectWindow {
                self.moveActiveWindow(to: frame)
            }
        } else {
            moveActiveWindow(to: frame)
        }
    }
    
    private func currentScreen() -> NSScreen? {
        if let window = activeWindow {
            print("[DEBUG] currentScreen: using activeWindow.")
            var windowFrameValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(window, kAXFrameAttribute as CFString, &windowFrameValue)
            print("[DEBUG] currentScreen: AXFrame result: \(result.rawValue)")
            if result == .success, let windowFrame = windowFrameValue as? CGRect {
                print("[DEBUG] currentScreen: Window frame: \(windowFrame)")
                if let screen = NSScreen.screens.first(where: { $0.frame.intersects(windowFrame) }) {
                    print("[DEBUG] currentScreen: Detected screen: \(screen.frame)")
                    return screen
                } else {
                    print("[DEBUG] currentScreen: Window does not belong to any screen.")
                }
            }
        } else {
            print("[DEBUG] currentScreen: activeWindow is nil, using main screen.")
        }
        return NSScreen.main
    }
}

private extension WindowManager {
    func makeFullScreen() {
        selectWindow {
            guard let screen = NSScreen.main else { return }
            let screenFrame = screen.frame
            
            let frame = NSRect(x: screenFrame.minX,
                               y: screenFrame.minY,
                               width: screenFrame.width,
                               height: screenFrame.height)
            
            self.moveActiveWindow(to: frame)
        }
    }
    
    func divideScreenIntoThirds(position: ScreenPosition.Third) {
        selectWindow {
            guard let screen = self.currentScreen() else {
                print("Could not determine current screen, defaulting to main screen.")
                return
            }
            let screenFrame = screen.frame
            print("Detected screen frame: \(screenFrame)")
            
            let width = screenFrame.width / 3
            let x: CGFloat
            switch position {
            case .left:
                x = screenFrame.minX
            case .center:
                x = screenFrame.minX + width
            case .right:
                x = screenFrame.minX + (width * 2)
            }
            
            let frame = NSRect(x: x,
                               y: screenFrame.minY,
                               width: width,
                               height: screenFrame.height)
            print("Calculated window frame: \(frame)")
            
            self.moveActiveWindow(to: frame)
        }
    }
    
    func divideScreenInHalf(position: ScreenPosition.Half) {
        selectWindow {
            guard let screen = self.currentScreen() else { return }
            let screenFrame = screen.frame
            
            let width = screenFrame.width / 2
            let x = position == .left ? screenFrame.minX : screenFrame.minX + width
            
            let frame = NSRect(x: x,
                               y: screenFrame.minY,
                               width: width,
                               height: screenFrame.height)
            self.moveActiveWindow(to: frame)
        }
    }
    
    func moveToCorner(position: ScreenPosition.Corner) {
        selectWindow {
            guard let screen = NSScreen.main else { return }
            let screenFrame = screen.frame
            
            let halfWidth = screenFrame.width / 2
            let halfHeight = screenFrame.height / 2
            
            let x: CGFloat
            let y: CGFloat
            
            switch position {
            case .topLeft:
                x = screenFrame.minX
                y = screenFrame.minY
            case .topRight:
                x = screenFrame.maxX - halfWidth
                y = screenFrame.minY
            case .bottomLeft:
                x = screenFrame.minX
                y = screenFrame.minY + halfHeight
            case .bottomRight:
                x = screenFrame.maxX - halfWidth
                y = screenFrame.minY + halfHeight
            }
            
            let frame = NSRect(x: x,
                               y: y,
                               width: halfWidth,
                               height: halfHeight)
            
            self.moveActiveWindow(to: frame)
        }
    }
    
    func divideScreenVertically(position: ScreenPosition.Vertical) {
        selectWindow {
            guard let screen = NSScreen.main else { return }
            let screenFrame = screen.frame
            
            let height = screenFrame.height / 2
            let y: CGFloat
            
            switch position {
            case .top:
                y = screenFrame.minY
            case .bottom:
                y = screenFrame.minY + height
            }
            
            let frame = NSRect(x: screenFrame.minX,
                               y: y,
                               width: screenFrame.width,
                               height: height)
            
            self.moveActiveWindow(to: frame)
        }
    }
    
    func centerWindow(withScale scale: CGFloat = 0.6) {
        selectWindow {
            guard let screen = NSScreen.main else { return }
            let screenFrame = screen.frame
            
            let width = screenFrame.width * scale
            let height = screenFrame.height * scale
            
            let x = screenFrame.minX + (screenFrame.width - width) / 2
            let y = screenFrame.minY + (screenFrame.height - height) / 2
            
            let frame = NSRect(x: x, y: y, width: width, height: height)
            self.moveActiveWindow(to: frame)
        }
    }
}

extension AXValue {
    static func from<T>(value: T, type: AXValueType) -> AXValue {
        var value = value
        return AXValueCreate(type, &value)!
    }
}
