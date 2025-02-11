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
                    button(for: .third(.left))
                    button(for: .third(.center))
                    button(for: .third(.right))
                }

                Divider()

                // Options for half split
                HStack {
                    button(for: .half(.left))
                    button(for: .half(.right))
                }

                Divider()

                // Corner options
                Grid {
                    GridRow {
                        button(for: .corner(.topLeft))
                        button(for: .corner(.topRight))
                    }
                    GridRow {
                        button(for: .corner(.bottomLeft))
                        button(for: .corner(.bottomRight))
                    }
                }

                Divider()

                // Other options
                HStack {
                    button(for: .vertical(.top))
                    button(for: .vertical(.bottom))
                }

                button(for: .generic(.fullScreen))
                button(for: .generic(.center))
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

private extension StatusBarView {
    func button(for screenPosition: ScreenPosition) -> some View {
        Button {
            windowManager.resize(screenPosition)
        } label: {
            let configuration = ModernButtonConfig.config(for: screenPosition)
            Label(configuration.title, systemImage: configuration.systemIconName)
        }
    }
}
