import SwiftUI

enum MomensTypography {
    case titleB24
    case titleB20
    case titleM20
    case bodyB16
    case bodyM16
    case bodyB14
    case bodyM14
    case bodyB12
    case bodyM12
    case captionB11
    case captionM11
    case captionB10
    case captionM10

    var font: Font {
        Font.custom(fontName, size: fontSize)
    }

    var lineSpacing: CGFloat {
        lineHeight - (UIFont(name: fontName, size: fontSize)?.lineHeight ?? fontSize)
    }

    var tracking: CGFloat {
        fontSize * -0.02
    }

    private var fontName: String {
        switch self {
        case .titleB24, .titleB20, .bodyB16, .bodyB14, .bodyB12,
                .captionB11, .captionB10:
            "SUIT-Bold"
        case .titleM20, .bodyM16, .bodyM14, .bodyM12,
                .captionM11, .captionM10:
            "SUIT-Medium"
        }
    }

    private var fontSize: CGFloat {
        switch self {
        case .titleB24:
            24
        case .titleB20, .titleM20:
            20
        case .bodyB16, .bodyM16:
            16
        case .bodyB14, .bodyM14:
            14
        case .bodyB12, .bodyM12:
            12
        case .captionB11, .captionM11:
            11
        case .captionB10, .captionM10:
            10
        }
    }

    private var lineHeight: CGFloat {
        switch self {
        case .titleB24:
            31.2
        case .titleB20, .titleM20:
            26
        case .bodyB16, .bodyM16:
            24
        case .bodyB14, .bodyM14:
            21
        case .bodyB12, .bodyM12:
            18
        case .captionB11, .captionM11:
            16.5
        case .captionB10, .captionM10:
            15
        }
    }
}

extension View {
    func momensFont(_ typography: MomensTypography) -> some View {
        font(typography.font)
            .lineSpacing(typography.lineSpacing)
            .tracking(typography.tracking)
    }
}
