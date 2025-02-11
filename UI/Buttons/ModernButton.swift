import SwiftUI

typealias ModernButtonAction = () -> Void

struct ModernButton: View {
    private let configuration: ModernButtonConfig
    private let action: ModernButtonAction
    
    init(configuration: ModernButtonConfig, action: @escaping ModernButtonAction) {
        self.configuration = configuration
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(ModernButtonStyle())
    }
}

private extension ModernButton {
    func label() -> some View {
        VStack(spacing: 10) {
            Image(systemName: configuration.systemIconName)
                .font(.system(size: 28))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accent, Color.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(configuration.title)
                .font(.custom("SF Pro Text", size: 14))
                .fontWeight(.medium)
        }
    }
}
