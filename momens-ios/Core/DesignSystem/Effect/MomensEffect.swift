import SwiftUI

enum MomensEffect {
    static let uiShadow = MomensShadow(
        color: .black.opacity(0.04),
        offsetX: 0,
        offsetY: 2,
        radius: 12
    )
    static let floatingShadow = MomensShadow(
        color: .black.opacity(0.25),
        offsetX: -1,
        offsetY: 4,
        radius: 4
    )
    static let bottomSheetShadow = MomensShadow(
        color: .black.opacity(0.25),
        offsetX: 0,
        offsetY: -6,
        radius: 16
    )
    static let navigationBlurRadius: CGFloat = 4
    static let navigationMaterial: Material = .ultraThinMaterial
}

struct MomensShadow {
    let color: Color
    let offsetX: CGFloat
    let offsetY: CGFloat
    let radius: CGFloat
}

extension View {
    func momensShadow(_ shadow: MomensShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.offsetX,
            y: shadow.offsetY
        )
    }
}
