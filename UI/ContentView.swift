import SwiftUI

// Custom color scheme
extension Color {
    static let accent = Color(red: 0.37, green: 0.47, blue: 0.97)
    static let secondaryAccent = Color(red: 0.95, green: 0.52, blue: 0.73)
    static let background = Color(red: 0.07, green: 0.08, blue: 0.14)
    static let surface = Color(red: 0.12, green: 0.14, blue: 0.22)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
}

struct ModernButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.surface)
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color.accent, Color.secondaryAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .foregroundColor(Color.textPrimary)
            .shadow(color: Color.accent.opacity(0.3), radius: 8, x: 0, y: 4)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct ContentView: View {
    let windowManager = WindowManager.shared
    @State private var viewWidth: CGFloat = 0
    
    private var isCompactWidth: Bool {
        viewWidth < 700
    }
    
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
                            // Compact layout
                            compactLayout
                        } else {
                            // Regular layout
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
    
    private var titleSection: some View {
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
    
    private var compactLayout: some View {
        VStack(spacing: 20) {
            // Corner Controls
            sectionTitle("Corner Controls")
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    cornerButton("Top Left", "arrow.up.left.square.fill", .topLeft)
                    cornerButton("Top Right", "arrow.up.right.square.fill", .topRight)
                }
                GridRow {
                    cornerButton("Bottom Left", "arrow.down.left.square.fill", .bottomLeft)
                    cornerButton("Bottom Right", "arrow.down.right.square.fill", .bottomRight)
                }
            }
            
            // Vertical Split
            sectionTitle("Vertical Split")
            HStack(spacing: 12) {
                verticalButton("Top Half", "rectangle.tophalf.filled", .top)
                verticalButton("Bottom Half", "rectangle.bottomhalf.filled", .bottom)
            }
            
            // 2/3 Split
            sectionTitle("2/3 Split")
            HStack(spacing: 12) {
                twoThirdsButton("Left 2/3", "rectangle.lefthalf.inset.filled", .left)
                twoThirdsButton("Right 2/3", "rectangle.righthalf.inset.filled", .right)
            }
            
            // Third Split
            sectionTitle("Third Split")
            VStack(spacing: 12) {
                thirdButton("Left 1/3", "rectangle.lefthalf.filled", .left)
                thirdButton("Center 1/3", "rectangle.center.filled", .center)
                thirdButton("Right 1/3", "rectangle.righthalf.filled", .right)
            }
            
            // Half Split
            sectionTitle("Half Split")
            VStack(spacing: 12) {
                halfButton("Left Half", "rectangle.lefthalf.filled", .left)
                halfButton("Right Half", "rectangle.righthalf.filled", .right)
            }
            
            // Other Controls
            sectionTitle("Other")
            VStack(spacing: 12) {
                Button(action: { windowManager.centerWindow() }) {
                    buttonContent("Center", "rectangle.center.filled")
                }
                .buttonStyle(ModernButtonStyle())
                
                Button(action: { windowManager.makeFullScreen() }) {
                    buttonContent("Full Screen", "rectangle.fill")
                }
                .buttonStyle(ModernButtonStyle())
            }
        }
    }
    
    private var regularLayout: some View {
        HStack(alignment: .top, spacing: 32) {
            // Left column
            VStack(spacing: 20) {
                sectionTitle("Corner Controls")
                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    GridRow {
                        cornerButton("Top Left", "arrow.up.left.square.fill", .topLeft)
                        cornerButton("Top Right", "arrow.up.right.square.fill", .topRight)
                    }
                    GridRow {
                        cornerButton("Bottom Left", "arrow.down.left.square.fill", .bottomLeft)
                        cornerButton("Bottom Right", "arrow.down.right.square.fill", .bottomRight)
                    }
                }
                
                sectionTitle("Vertical Split")
                HStack(spacing: 16) {
                    verticalButton("Top Half", "rectangle.tophalf.filled", .top)
                    verticalButton("Bottom Half", "rectangle.bottomhalf.filled", .bottom)
                }
                
                sectionTitle("2/3 Split")
                HStack(spacing: 16) {
                    twoThirdsButton("Left 2/3", "rectangle.lefthalf.inset.filled", .left)
                    twoThirdsButton("Right 2/3", "rectangle.righthalf.inset.filled", .right)
                }
            }
            
            // Middle column
            VStack(spacing: 20) {
                sectionTitle("Third Split")
                VStack(spacing: 16) {
                    thirdButton("Left 1/3", "rectangle.lefthalf.filled", .left)
                    thirdButton("Center 1/3", "rectangle.center.filled", .center)
                    thirdButton("Right 1/3", "rectangle.righthalf.filled", .right)
                }
            }
            
            // Right column
            VStack(spacing: 20) {
                sectionTitle("Half Split")
                VStack(spacing: 16) {
                    halfButton("Left Half", "rectangle.lefthalf.filled", .left)
                    halfButton("Right Half", "rectangle.righthalf.filled", .right)
                }
                
                sectionTitle("Other")
                VStack(spacing: 16) {
                    Button(action: { windowManager.centerWindow() }) {
                        buttonContent("Center", "rectangle.center.filled")
                    }
                    .buttonStyle(ModernButtonStyle())
                    
                    Button(action: { windowManager.makeFullScreen() }) {
                        buttonContent("Full Screen", "rectangle.fill")
                    }
                    .buttonStyle(ModernButtonStyle())
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var shortcutsSection: some View {
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
    
    private func shortcutRow(_ title: String, _ shortcut: String) -> some View {
        HStack {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .trailing)
            shortcutView(text: shortcut)
        }
    }
    
    private func shortcutView(text: String) -> some View {
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
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.custom("SF Pro Text", size: 16))
            .fontWeight(.semibold)
            .foregroundColor(.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func buttonContent(_ title: String, _ icon: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accent, Color.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(title)
                .font(.custom("SF Pro Text", size: 14))
                .fontWeight(.medium)
        }
    }
    
    private func cornerButton(_ title: String, _ icon: String, _ position: ScreenPosition.Corner) -> some View {
        Button(action: { windowManager.moveToCorner(position: position) }) {
            buttonContent(title, icon)
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    private func verticalButton(_ title: String, _ icon: String, _ position: ScreenPosition.Vertical) -> some View {
        Button(action: { windowManager.divideScreenVertically(position: position) }) {
            buttonContent(title, icon)
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    private func thirdButton(_ title: String, _ icon: String, _ position: ScreenPosition.Third) -> some View {
        Button(action: { windowManager.divideScreenIntoThirds(position: position) }) {
            buttonContent(title, icon)
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    private func halfButton(_ title: String, _ icon: String, _ position: ScreenPosition.Half) -> some View {
        Button(action: { windowManager.divideScreenInHalf(position: position) }) {
            buttonContent(title, icon)
        }
        .buttonStyle(ModernButtonStyle())
    }
    
    private func twoThirdsButton(_ title: String, _ icon: String, _ position: ScreenPosition.TwoThirds) -> some View {
        Button(action: { windowManager.divideScreenIntoTwoThirds(position: position) }) {
            buttonContent(title, icon)
        }
        .buttonStyle(ModernButtonStyle())
    }
}

// Helper views and preference key
private struct ViewWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct BackgroundPattern: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                for i in stride(from: 0, to: geometry.size.width, by: 40) {
                    for j in stride(from: 0, to: geometry.size.height, by: 40) {
                        path.addEllipse(in: CGRect(x: i, y: j, width: 2, height: 2))
                    }
                }
            }
            .fill(Color.accent.opacity(0.1))
        }
    }
}

#Preview {
    ContentView()
}
