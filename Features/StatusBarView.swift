//
//  StatusBarView.swift
//  ekranBolme
//
//  Created by Ömer Murat Aydın on 7.02.2025.
//

import SwiftUI

struct StatusBarView: View {
    let windowManager = WindowManager.shared

    var body: some View {
        VStack(spacing: 8) {
            Group {
                // Options for third split
                HStack {
                    Button(action: { windowManager.resize(.third(.left)) }) {
                        Label("Left 1/3", systemImage: "rectangle.lefthalf.filled")
                    }
                    Button(action: { windowManager.resize(.third(.center)) }) {
                        Label("Center 1/3", systemImage: "rectangle.center.filled")
                    }
                    Button(action: { windowManager.resize(.third(.right)) }) {
                        Label("Right 1/3", systemImage: "rectangle.righthalf.filled")
                    }
                }

                Divider()

                // Options for half split
                HStack {
                    Button(action: { windowManager.resize(.half(.left)) }) {
                        Label("Left Half", systemImage: "rectangle.lefthalf.filled")
                    }
                    Button(action: { windowManager.resize(.half(.right)) }) {
                        Label("Right Half", systemImage: "rectangle.righthalf.filled")
                    }
                }

                Divider()

                // Corner options
                Grid {
                    GridRow {
                        Button(action: { windowManager.resize(.corner(.topLeft)) }) {
                            Label("Top Left", systemImage: "arrow.up.left.square")
                        }
                        Button(action: { windowManager.resize(.corner(.topRight)) }) {
                            Label("Top Right", systemImage: "arrow.up.right.square")
                        }
                    }
                    GridRow {
                        Button(action: { windowManager.resize(.corner(.bottomLeft)) }) {
                            Label("Bottom Left", systemImage: "arrow.down.left.square")
                        }
                        Button(action: { windowManager.resize(.corner(.bottomRight)) }) {
                            Label("Bottom Right", systemImage: "arrow.down.right.square")
                        }
                    }
                }

                Divider()

                // Other options
                HStack {
                    Button(action: { windowManager.resize(.vertical(.top)) }) {
                        Label("Top Half", systemImage: "rectangle.tophalf.filled")
                    }
                    Button(action: { windowManager.resize(.vertical(.bottom)) }) {
                        Label("Bottom Half", systemImage: "rectangle.bottomhalf.filled")
                    }
                }

                Button(action: { windowManager.resize(.generic(.fullScreen)) }) {
                    Label("Full Screen", systemImage: "rectangle.fill")
                }

                Button(action: { windowManager.resize(.generic(.center)) }) {
                    Label("Center", systemImage: "rectangle.center.filled")
                }
            }
            .buttonStyle(.bordered)

            Divider()

            Button("Exit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
    }
}
