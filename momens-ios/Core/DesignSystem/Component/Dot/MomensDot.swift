import SwiftUI

struct MomensDot: View {
    let size: CGFloat
    let color: Color

    init(size: CGFloat = 2, color: Color = MomensColor.gray900) {
        self.size = size
        self.color = color
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

#Preview("MomensDot") {
    MomensDot()
        .padding(16)
}
