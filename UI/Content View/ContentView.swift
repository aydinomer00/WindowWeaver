import SwiftUI

struct ContentView: View {
    let windowManager = WindowManager.shared
    @State private var viewWidth: CGFloat = 0
    
    private var isCompactWidth: Bool { viewWidth < 700 }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        colors: [
                            Color.background,
                            Color.background.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Background pattern
                    BackgroundPattern()
                    
                    VStack(spacing: isCompactWidth ? 16 : 24) {
                        // Title section
                        titleSection
                            .padding(.top, isCompactWidth ? 16 : 24)
                        
                        if isCompactWidth {
                            compactLayout
                        } else {
                            regularLayout
                        }
                        
                        // Shortcuts section
                        shortcutsSection
                            .padding(.vertical, isCompactWidth ? 16 : 24)
                    }
                    .padding(isCompactWidth ? 12 : 24)
                }
            }
        }
        .background(
            GeometryReader { geometry in
                Color.clear.preference(key: ViewWidthKey.self, value: geometry.size.width)
            }
        )
        .onPreferenceChange(ViewWidthKey.self) { width in
            self.viewWidth = width
        }
        .frame(minWidth: 500, minHeight: isCompactWidth ? 800 : 680)
        .preferredColorScheme(.dark)
    }
}

private extension ContentView {
    var titleSection: some View {
        VStack(spacing: 12) {
            Text("WindowWeaver")
                .font(.custom("SF Pro Display", size: isCompactWidth ? 32 : 40, relativeTo: .title))
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accent, Color.secondaryAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Advanced Window Management")
                .font(.custom("SF Pro Text", size: isCompactWidth ? 16 : 18))
                .foregroundColor(.textSecondary)
        }
    }
    
    var compactLayout: some View {
        VStack(spacing: 20) {
            // Corner Controls
            sectionTitle("Corner Controls")
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    button(for: .corner(.topLeft))
                    button(for: .corner(.topRight))
                }
                GridRow {
                    button(for: .corner(.bottomLeft))
                    button(for: .corner(.bottomRight))
                }
            }
            
            sectionTitle("Vertical Split")
            HStack(spacing: 12) {
                button(for: .vertical(.top))
                button(for: .vertical(.bottom))
            }
            
            sectionTitle("2/3 Split")
            HStack(spacing: 12) {
                button(for: .twoThirds(.left))
                button(for: .twoThirds(.right))
            }
            
            sectionTitle("Third Split")
            VStack(spacing: 12) {
                button(for: .third(.left))
                button(for: .third(.center))
                button(for: .third(.right))
            }
            
            sectionTitle("Half Split")
            VStack(spacing: 12) {
                button(for: .half(.left))
                button(for: .half(.right))
            }
            
            sectionTitle("Other")
            VStack(spacing: 12) {
                button(for: .generic(.center))
                button(for: .generic(.fullScreen))
            }
        }
    }
    
    var regularLayout: some View {
        HStack(alignment: .top, spacing: 32) {
            // Left column
            VStack(spacing: 20) {
                sectionTitle("Corner Controls")
                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        button(for: .corner(.topLeft))
                        button(for: .corner(.topRight))
                    }
                    GridRow {
                        button(for: .corner(.bottomLeft))
                        button(for: .corner(.bottomRight))
                    }
                }
                
                sectionTitle("Vertical Split")
                HStack(spacing: 16) {
                    button(for: .vertical(.top))
                    button(for: .vertical(.bottom))
                }
                
                sectionTitle("2/3 Split")
                HStack(spacing: 16) {
                    button(for: .twoThirds(.left))
                    button(for: .twoThirds(.right))
                }
            }
            
            // Middle column
            VStack(spacing: 20) {
                sectionTitle("Third Split")
                VStack(spacing: 16) {
                    button(for: .third(.left))
                    button(for: .third(.center))
                    button(for: .third(.right))
                }
            }
            
            // Right column
            VStack(spacing: 20) {
                sectionTitle("Half Split")
                VStack(spacing: 16) {
                    button(for: .half(.left))
                    button(for: .half(.right))
                }
                
                sectionTitle("Other")
                VStack(spacing: 16) {
                    button(for: .generic(.center))
                    button(for: .generic(.fullScreen))
                }
            }
        }
        .padding(.horizontal)
    }
    
    var shortcutsSection: some View {
        VStack(spacing: 16) {
            Text("Keyboard Shortcuts")
                .font(.custom("SF Pro Text", size: isCompactWidth ? 16 : 18))
                .foregroundColor(.textSecondary)
            
            if isCompactWidth {
                // Compact shortcuts layout
                VStack(spacing: 8) {
                    shortcutRow("2/3 Split", "⌘ + ⌥ + ⇧ + ←/→")
                    shortcutRow("1/3 Split", "⌘ + ⇧ + ←/↓/→")
                    shortcutRow("Half Split", "⌘ + ⌃ + ←/→")
                    shortcutRow("Full Screen", "⌘ + ⌃ + ↵")
                    shortcutRow("Center", "⌘ + ⌃ + Space")
                }
            } else {
                // Regular shortcuts layout
                Grid(horizontalSpacing: 24, verticalSpacing: 12) {
                    GridRow {
                        Text("2/3 Split")
                            .gridColumnAlignment(.trailing)
                        shortcutView(text: "⌘ + ⌥ + ⇧ + ←/→")
                    }
                    GridRow {
                        Text("1/3 Split")
                        shortcutView(text: "⌘ + ⇧ + ←/↓/→")
                    }
                    GridRow {
                        Text("Half Split")
                        shortcutView(text: "⌘ + ⌃ + ←/→")
                    }
                    GridRow {
                        Text("Full Screen")
                        shortcutView(text: "⌘ + ⌃ + ↵")
                    }
                    GridRow {
                        Text("Center")
                        shortcutView(text: "⌘ + ⌃ + Space")
                    }
                }
                .font(.custom("SF Pro Text", size: 14))
                .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.accent.opacity(0.3), Color.secondaryAccent.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
    
    func button(for screenPosition: ScreenPosition) -> some View {
        ModernButton(configuration: .config(for: screenPosition)) {
            windowManager.resize(screenPosition)
        }
    }
    
    func shortcutRow(_ title: String, _ shortcut: String) -> some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .trailing)
            shortcutView(text: shortcut)
        }
    }
    
    func shortcutView(text: String) -> some View {
        Text(text)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.background)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accent.opacity(0.3), lineWidth: 1)
                    )
            )
    }
    
    func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.custom("SF Pro Text", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
