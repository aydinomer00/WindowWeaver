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
    
    var body: some View {
        ZStack {
            // Enhanced background gradient
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
            
            VStack(spacing: 24) {
                // Enhanced title section
                VStack(spacing: 12) {
                    Text("WindowWeaver")
                        .font(.custom("SF Pro Display", size: 40, relativeTo: .title))
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.accent, Color.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Advanced Window Management")
                        .font(.custom("SF Pro Text", size: 18))
                        .foregroundColor(.textSecondary)
                }
                .padding(.top, 24)
                
                // Main control grid
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
                
                // Enhanced shortcuts section
                VStack(spacing: 16) {
                    Text("Keyboard Shortcuts")
                        .font(.custom("SF Pro Text", size: 18))
                        .foregroundColor(.textSecondary)
                    
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
                .padding(.vertical, 24)
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
                .padding(.horizontal)
            }
            .padding()
        }
        .frame(minWidth: 860, minHeight: 680)
        .preferredColorScheme(.dark)
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

#Preview {
    ContentView()
}
