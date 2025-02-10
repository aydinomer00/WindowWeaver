//
//  StatusBarView.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

// StatusBarView.swift
import SwiftUI

struct StatusBarView: View {
    let windowManager = WindowManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Group {
                // Üçe bölme seçenekleri
                HStack {
                    Button(action: { windowManager.divideScreenIntoThirds(position: .left) }) {
                        Label("Sol 1/3", systemImage: "rectangle.lefthalf.filled")
                    }
                    Button(action: { windowManager.divideScreenIntoThirds(position: .center) }) {
                        Label("Orta 1/3", systemImage: "rectangle.center.filled")
                    }
                    Button(action: { windowManager.divideScreenIntoThirds(position: .right) }) {
                        Label("Sağ 1/3", systemImage: "rectangle.righthalf.filled")
                    }
                }
                
                Divider()
                
                // İkiye bölme seçenekleri
                HStack {
                    Button(action: { windowManager.divideScreenInHalf(position: .left) }) {
                        Label("Sol Yarım", systemImage: "rectangle.lefthalf.filled")
                    }
                    Button(action: { windowManager.divideScreenInHalf(position: .right) }) {
                        Label("Sağ Yarım", systemImage: "rectangle.righthalf.filled")
                    }
                }
                
                Divider()
                
                // Köşe seçenekleri
                Grid {
                    GridRow {
                        Button(action: { windowManager.moveToCorner(position: .topLeft) }) {
                            Label("Sol Üst", systemImage: "arrow.up.left.square")
                        }
                        Button(action: { windowManager.moveToCorner(position: .topRight) }) {
                            Label("Sağ Üst", systemImage: "arrow.up.right.square")
                        }
                    }
                    GridRow {
                        Button(action: { windowManager.moveToCorner(position: .bottomLeft) }) {
                            Label("Sol Alt", systemImage: "arrow.down.left.square")
                        }
                        Button(action: { windowManager.moveToCorner(position: .bottomRight) }) {
                            Label("Sağ Alt", systemImage: "arrow.down.right.square")
                        }
                    }
                }
                
                Divider()
                
                // Diğer seçenekler
                HStack {
                    Button(action: { windowManager.divideScreenVertically(position: .top) }) {
                        Label("Üst Yarım", systemImage: "rectangle.tophalf.filled")
                    }
                    Button(action: { windowManager.divideScreenVertically(position: .bottom) }) {
                        Label("Alt Yarım", systemImage: "rectangle.bottomhalf.filled")
                    }
                }
                
                Button(action: { windowManager.makeFullScreen() }) {
                    Label("Tam Ekran", systemImage: "rectangle.fill")
                }
                
                Button(action: { windowManager.centerWindow() }) {
                    Label("Merkez", systemImage: "rectangle.center.filled")
                }
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            Button("Çıkış") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}
