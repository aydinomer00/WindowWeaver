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
    
    enum Generic {
        case center
        case fullScreen
    }
    
    case corner(_ position: Corner)
    case half(_ position: Half)
    case third(_ position: Third)
    case twoThirds(_ position: TwoThirds)
    case vertical(_ position: Vertical)
    case generic(_ position: Generic)
}
