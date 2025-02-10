//
//  StatusBarController.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

import Cocoa
import SwiftUI

class StatusBarController: ObservableObject {
    static let shared = StatusBarController()
    private var statusItem: NSStatusItem?
    private let windowManager = WindowManager.shared
    
    private init() {
        DispatchQueue.main.async {
            self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            self.setupUI()
            self.setupMenus()
        }
    }
    
    private func setupUI() {
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "rectangle.split.3x1", accessibilityDescription: nil)
        }
    }
    
    private func setupMenus() {
        let menu = NSMenu()
        
        // 2/3 Split Menu Items
        let leftTwoThirdsItem = NSMenuItem(title: "Left 2/3", action: #selector(leftTwoThirds), keyEquivalent: "")
        leftTwoThirdsItem.target = self
        menu.addItem(leftTwoThirdsItem)
        
        let rightTwoThirdsItem = NSMenuItem(title: "Right 2/3", action: #selector(rightTwoThirds), keyEquivalent: "")
        rightTwoThirdsItem.target = self
        menu.addItem(rightTwoThirdsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 1/3 Split Menu Items
        let leftThirdItem = NSMenuItem(title: "Left 1/3", action: #selector(leftThird), keyEquivalent: "")
        leftThirdItem.target = self
        menu.addItem(leftThirdItem)
        
        let centerThirdItem = NSMenuItem(title: "Center 1/3", action: #selector(centerThird), keyEquivalent: "")
        centerThirdItem.target = self
        menu.addItem(centerThirdItem)
        
        let rightThirdItem = NSMenuItem(title: "Right 1/3", action: #selector(rightThird), keyEquivalent: "")
        rightThirdItem.target = self
        menu.addItem(rightThirdItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Half Split Menu Items
        let leftHalfItem = NSMenuItem(title: "Left Half", action: #selector(leftHalf), keyEquivalent: "")
        leftHalfItem.target = self
        menu.addItem(leftHalfItem)
        
        let rightHalfItem = NSMenuItem(title: "Right Half", action: #selector(rightHalf), keyEquivalent: "")
        rightHalfItem.target = self
        menu.addItem(rightHalfItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Corner Controls
        let cornersSubmenu = NSMenu()
        
        let topLeftItem = NSMenuItem(title: "Top Left", action: #selector(topLeft), keyEquivalent: "")
        topLeftItem.target = self
        cornersSubmenu.addItem(topLeftItem)
        
        let topRightItem = NSMenuItem(title: "Top Right", action: #selector(topRight), keyEquivalent: "")
        topRightItem.target = self
        cornersSubmenu.addItem(topRightItem)
        
        let bottomLeftItem = NSMenuItem(title: "Bottom Left", action: #selector(bottomLeft), keyEquivalent: "")
        bottomLeftItem.target = self
        cornersSubmenu.addItem(bottomLeftItem)
        
        let bottomRightItem = NSMenuItem(title: "Bottom Right", action: #selector(bottomRight), keyEquivalent: "")
        bottomRightItem.target = self
        cornersSubmenu.addItem(bottomRightItem)
        
        let cornersItem = NSMenuItem(title: "Corners", action: nil, keyEquivalent: "")
        cornersItem.submenu = cornersSubmenu
        menu.addItem(cornersItem)
        
        // Vertical Split
        let verticalSubmenu = NSMenu()
        
        let topHalfItem = NSMenuItem(title: "Top Half", action: #selector(topHalf), keyEquivalent: "")
        topHalfItem.target = self
        verticalSubmenu.addItem(topHalfItem)
        
        let bottomHalfItem = NSMenuItem(title: "Bottom Half", action: #selector(bottomHalf), keyEquivalent: "")
        bottomHalfItem.target = self
        verticalSubmenu.addItem(bottomHalfItem)
        
        let verticalItem = NSMenuItem(title: "Vertical Split", action: nil, keyEquivalent: "")
        verticalItem.submenu = verticalSubmenu
        menu.addItem(verticalItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Other Controls
        let centerItem = NSMenuItem(title: "Center", action: #selector(center), keyEquivalent: "")
        centerItem.target = self
        menu.addItem(centerItem)
        
        let fullScreenItem = NSMenuItem(title: "Full Screen", action: #selector(fullScreen), keyEquivalent: "")
        fullScreenItem.target = self
        menu.addItem(fullScreenItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    // 2/3 Split Actions
    @objc private func leftTwoThirds() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenIntoTwoThirds(position: .left)
        }
    }
    
    @objc private func rightTwoThirds() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenIntoTwoThirds(position: .right)
        }
    }
    
    // 1/3 Split Actions
    @objc private func leftThird() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenIntoThirds(position: .left)
        }
    }
    
    @objc private func centerThird() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenIntoThirds(position: .center)
        }
    }
    
    @objc private func rightThird() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenIntoThirds(position: .right)
        }
    }
    
    // Half Split Actions
    @objc private func leftHalf() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenInHalf(position: .left)
        }
    }
    
    @objc private func rightHalf() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenInHalf(position: .right)
        }
    }
    
    // Corner Actions
    @objc private func topLeft() {
        DispatchQueue.main.async {
            self.windowManager.moveToCorner(position: .topLeft)
        }
    }
    
    @objc private func topRight() {
        DispatchQueue.main.async {
            self.windowManager.moveToCorner(position: .topRight)
        }
    }
    
    @objc private func bottomLeft() {
        DispatchQueue.main.async {
            self.windowManager.moveToCorner(position: .bottomLeft)
        }
    }
    
    @objc private func bottomRight() {
        DispatchQueue.main.async {
            self.windowManager.moveToCorner(position: .bottomRight)
        }
    }
    
    // Vertical Split Actions
    @objc private func topHalf() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenVertically(position: .top)
        }
    }
    
    @objc private func bottomHalf() {
        DispatchQueue.main.async {
            self.windowManager.divideScreenVertically(position: .bottom)
        }
    }
    
    // Other Actions
    @objc private func center() {
        DispatchQueue.main.async {
            self.windowManager.centerWindow()
        }
    }
    
    @objc private func fullScreen() {
        DispatchQueue.main.async {
            self.windowManager.makeFullScreen()
        }
    }
}
