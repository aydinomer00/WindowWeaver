//
//  WindowManager.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

// WindowManager.swift
import Cocoa
import Carbon
import ApplicationServices

let kAXFrameAttribute: CFString = "AXFrame" as CFString
let kAXSizeAttribute: CFString = "AXSize" as CFString
let kAXPositionAttribute: CFString = "AXPosition" as CFString


enum ScreenPosition {
    enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    enum Half {
        case left, right
    }
    
    enum Third {
        case left, center, right
    }
    
    enum TwoThirds {
            case left, right
        }
    
    enum Vertical {
        case top, bottom
    }
    
}

class WindowManager: ObservableObject {
    static let shared = WindowManager()
    private var selectedApp: NSRunningApplication?
    private var activeWindow: AXUIElement?
    
    private init() {
        checkAccessibilityPermissions()
    }
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "Erişilebilirlik İzni Gerekli"
                alert.informativeText = "Bu uygulamanın tam olarak çalışabilmesi için System Settings > Privacy & Security > Accessibility'den izin vermeniz gerekiyor."
                alert.addButton(withTitle: "Ayarları Aç")
                alert.addButton(withTitle: "İptal")
                
                if alert.runModal() == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
    }
    

    func repositionWindowUsingAppleScript(for app: NSRunningApplication, position: ScreenPosition.Third) {
        guard let appName = app.localizedName, let screen = NSScreen.main else {
            print("Uygulama adı veya ana ekran alınamadı.")
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
                print("AppleScript hatası: \(error)")
            } else {
                print("\(appName) uygulamasının penceresi \(newFrame) konumuna taşındı. Sonuç: \(result.stringValue ?? "Başarılı")")
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
                        
                        // Hangi ekran üzerinde olduğunu tespit edelim
                        let windowScreen = NSScreen.screens.first { $0.frame.intersects(frame) } ?? NSScreen.main!
                        let screenFrame = windowScreen.frame
                        
                        // Ekranı üçe bölme hesaplaması (örneğin; sağ üçte için)
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
                        
                        // Pencereyi yeni konuma taşıyalım
                        let newPos = AXValue.from(value: newFrame.origin, type: .cgPoint)
                        let newSize = AXValue.from(value: newFrame.size, type: .cgSize)
                        AXUIElementSetAttributeValue(window, kAXPositionAttribute, newPos)
                        AXUIElementSetAttributeValue(window, kAXSizeAttribute, newSize)
                        
                        print("\(app.localizedName ?? "Bilinmeyen") uygulamasının penceresi \(newFrame) konumuna taşındı.")
                    } else {
                        print("\(app.localizedName ?? "Bilinmeyen") uygulamasının pencere çerçevesi alınamadı.")
                    }
                }
            } else {
                print("\(app.localizedName ?? "Bilinmeyen") uygulamasının pencere listesi alınamadı.")
            }
        }
    }


    func repositionTextEditWindowToRightThird() {
        guard let screen = NSScreen.main else {
            print("Ana ekran alınamadı.")
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
                print("AppleScript hatası: \(error)")
            } else {
                print("TextEdit penceresi \(newFrame) konumuna taşındı. Sonuç: \(result.stringValue ?? "Başarılı")")
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
        // Sistemde önde olan uygulamayı alıyoruz
        if let frontmostApp = NSWorkspace.shared.frontmostApplication,
           frontmostApp.bundleIdentifier != Bundle.main.bundleIdentifier {
            // Eğer aktif uygulama bizim uygulamamız değilse, onu hedef alıyoruz
            self.selectedApp = frontmostApp
            frontmostApp.activate(options: .activateIgnoringOtherApps)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateActiveWindow()
                completion()
            }
        } else if let _ = self.selectedApp {
            // Eğer önde olan uygulama bizim uygulamamız ise (örneğin status bar’dan tıklandığında),
            // daha önce seçilmiş olan pencereyi kullanmaya devam ediyoruz.
            DispatchQueue.main.async {
                self.updateActiveWindow()
                completion()
            }
        } else {
            // Eğer hiçbir geçerli pencere bulunamazsa, fallback olarak seçim diyalogu gösteriyoruz.
            let apps = NSWorkspace.shared.runningApplications.filter {
                $0.activationPolicy == .regular && $0.bundleIdentifier != Bundle.main.bundleIdentifier
            }
            
            let alert = NSAlert()
            alert.messageText = "Pencere Seçin"
            alert.informativeText = "İşlem yapılacak pencereyi seçin"
            for (index, app) in apps.enumerated() {
                if let name = app.localizedName {
                    alert.addButton(withTitle: "\(index): \(name)")
                }
            }
            alert.addButton(withTitle: "İptal")
            
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

    
    private func isAccessibilityEnabled() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    private func updateActiveWindow() {
        
        if !AXIsProcessTrusted() {
                print("[DEBUG] Erişilebilirlik izni verilmemiş, izin isteniyor...")
                let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
                let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
                if !accessEnabled {
                    print("[DEBUG] Erişilebilirlik izni reddedildi")
                    return
                }
            }
        
        guard let app = selectedApp else {
            print("[DEBUG] updateActiveWindow: selectedApp nil.")
            return
        }
        print("[DEBUG] updateActiveWindow: Seçilen uygulama: \(app.localizedName ?? "Bilinmeyen") (PID: \(app.processIdentifier))")
        let appRef = AXUIElementCreateApplication(app.processIdentifier)
        
        var window: CFTypeRef?
        // İlk olarak odaklanmış pencere (AXFocusedWindow) deneniyor.
        let resultFocused = AXUIElementCopyAttributeValue(appRef, kAXFocusedWindowAttribute as CFString, &window)
        print("[DEBUG] AXFocusedWindow sonucu: \(resultFocused.rawValue)")
        
        // Eğer AXFocusedWindow başarısız olursa, ana pencere (AXMainWindow) deneniyor.
        if resultFocused != .success || window == nil {
            print("[DEBUG] Odaklı pencere alınamadı, AXMainWindow deneniyor.")
            let resultMain = AXUIElementCopyAttributeValue(appRef, "AXMainWindow" as CFString, &window)
            print("[DEBUG] AXMainWindow sonucu: \(resultMain.rawValue)")
        }
        
        // Yine window değeri alınamadıysa, AXWindows listesinden ilk pencereyi seçmeye çalışıyoruz.
        if window == nil {
            print("[DEBUG] Odaklı ve ana pencere alınamadı, AXWindows deneniyor.")
            var windowList: CFTypeRef?
            let resultWindows = AXUIElementCopyAttributeValue(appRef, "AXWindows" as CFString, &windowList)
            print("[DEBUG] AXWindows sonucu: \(resultWindows.rawValue)")
            if resultWindows == .success, let windows = windowList as? [AXUIElement], !windows.isEmpty {
                print("[DEBUG] \(windows.count) pencere bulundu, ilk pencere seçiliyor.")
                window = windows[0]
            } else {
                print("[DEBUG] AXWindows değeri alınamadı veya boş.")
            }
        }
        
        if let window = window {
            activeWindow = window as! AXUIElement
            print("[DEBUG] activeWindow güncellendi.")
            var frameValue: CFTypeRef?
            let resultFrame = AXUIElementCopyAttributeValue(activeWindow!, kAXFrameAttribute as CFString, &frameValue)
            print("[DEBUG] AXFrame sonucu: \(resultFrame.rawValue)")
            if resultFrame == .success, let frame = frameValue as? CGRect {
                print("[DEBUG] Güncellenen pencere çerçevesi: \(frame)")
            } else {
                print("[DEBUG] Pencere çerçevesi alınamadı.")
            }
        } else {
            print("[DEBUG] updateActiveWindow: Pencere bilgisi alınamadı.")
        }
    }



    
    private func moveActiveWindow(to frame: NSRect) {
        guard let window = activeWindow else {
            print("[DEBUG] moveActiveWindow: activeWindow nil, pencere taşınamıyor.")
            return
        }
        print("[DEBUG] Pencere taşınacak frame: \(frame)")
        var point = AXValue.from(value: frame.origin, type: .cgPoint)
        var size = AXValue.from(value: frame.size, type: .cgSize)
        
        let resultPos = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, point)
        print("[DEBUG] Konum ayarlama sonucu: \(resultPos)")
        let resultSize = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size)
        print("[DEBUG] Boyut ayarlama sonucu: \(resultSize)")
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
    // Ekranı üçe bölme
    func divideScreenIntoThirds(position: ScreenPosition.Third) {
        selectWindow {
            guard let screen = self.currentScreen() else {
                print("currentScreen döndüremedi, varsayılan olarak ana ekran kullanılıyor")
                return
            }
            let screenFrame = screen.frame
            print("Tespit edilen ekran çerçevesi: \(screenFrame)")

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
            print("Hesaplanan pencere çerçevesi: \(frame)")
            
            self.moveActiveWindow(to: frame)
        }
    }


    
    // İkiye bölme
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

    
    // Köşelere taşıma
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
    
    // Dikey bölme
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
    
    // Merkeze alma
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
    
    
    private func currentScreen() -> NSScreen? {
        if let window = activeWindow {
            print("[DEBUG] currentScreen: activeWindow kullanılıyor.")
            var windowFrameValue: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(window, kAXFrameAttribute as CFString, &windowFrameValue)
            print("[DEBUG] currentScreen: AXFrame sonucu: \(result.rawValue)")
            if result == .success, let windowFrame = windowFrameValue as? CGRect {
                print("[DEBUG] currentScreen: Pencere çerçevesi: \(windowFrame)")
                if let screen = NSScreen.screens.first(where: { $0.frame.intersects(windowFrame) }) {
                    print("[DEBUG] currentScreen: Tespit edilen ekran: \(screen.frame)")
                    return screen
                } else {
                    print("[DEBUG] currentScreen: Pencere herhangi bir ekrana ait değil.")
                }
            }
        } else {
            print("[DEBUG] currentScreen: activeWindow nil, ana ekran kullanılıyor.")
        }
        return NSScreen.main
    }

    // Tam ekran
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
}

// AXValue yardımcı extension
extension AXValue {
    static func from<T>(value: T, type: AXValueType) -> AXValue {
        var value = value
        return AXValueCreate(type, &value)!
    }
}
