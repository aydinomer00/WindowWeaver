import SwiftUI

struct BackgroundPattern: View {
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
