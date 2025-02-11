struct ModernButtonConfig {
    let title: String
    let systemIconName: String
}

extension ModernButtonConfig {
    static func config(for screenPosition: ScreenPosition) -> ModernButtonConfig {
        switch screenPosition {
        case let .corner(position):
            return config(for: position)
        case let .half(position):
            return config(for: position)
        case let .third(position):
            return config(for: position)
        case let .twoThirds(position):
            return config(for: position)
        case let .vertical(position):
            return config(for: position)
        case let .generic(position):
            return config(for: position)
        }
    }
}

private extension ModernButtonConfig {
    static func config(for position: ScreenPosition.Corner) -> ModernButtonConfig {
        switch position {
        case .topLeft:
            return .init(title: "Top Left", systemIconName: "arrow.up.left.square.fill")
        case .topRight:
            return .init(title: "Top Right", systemIconName: "arrow.up.right.square.fill")
        case .bottomLeft:
            return .init(title: "Bottom Left", systemIconName: "arrow.down.left.square.fill")
        case .bottomRight:
            return .init(title: "Bottom Right", systemIconName: "arrow.down.right.square.fill")
        }
    }

    static func config(for position: ScreenPosition.Half) -> ModernButtonConfig {
        switch position {
        case .left:
            return .init(title: "Left Half", systemIconName: "rectangle.lefthalf.filled")
        case .right:
            return .init(title: "Right Half", systemIconName: "rectangle.righthalf.filled")
        }
    }

    static func config(for position: ScreenPosition.Third) -> ModernButtonConfig {
        switch position {
        case .left:
            return .init(title: "Left 1/3", systemIconName: "rectangle.lefthalf.filled")
        case .center:
            return .init(title: "Center 1/3", systemIconName: "rectangle.center.filled")
        case .right:
            return .init(title: "Right 1/3", systemIconName: "rectangle.righthalf.filled")
        }
    }
    
    static func config(for position: ScreenPosition.TwoThirds) -> ModernButtonConfig {
        switch position {
        case .left:
            return .init(title: "Left 2/3", systemIconName: "rectangle.lefthalf.inset.filled")
        case .right:
            return .init(title: "Right 2/3", systemIconName: "rectangle.righthalf.inset.filled")
        }
    }
    
    static func config(for position: ScreenPosition.Vertical) -> ModernButtonConfig {
        switch position {
        case .top:
            return .init(title: "Top Half", systemIconName: "rectangle.tophalf.filled")
        case .bottom:
            return .init(title: "Bottom Half", systemIconName: "rectangle.bottomhalf.filled")
        }
    }
    
    static func config(for position: ScreenPosition.Generic) -> ModernButtonConfig {
        switch position {
        case .center:
            return .init(title: "Center", systemIconName: "rectangle.center.filled")
        case .fullScreen:
            return .init(title: "Full Screen", systemIconName: "rectangle.fill")
        }
    }
}
