import CoreText
import Foundation
import SwiftUI
import UIKit

enum MomensTypography {
    case titleBold24
    case titleBold20
    case titleMedium20
    case bodyBold16
    case bodyMedium16
    case bodyBold14
    case bodyMedium14
    case bodyBold12
    case bodyMedium12
    case captionBold11
    case captionMedium11
    case captionBold10
    case captionMedium10

    static func registerFonts() {
        ["SUIT-Bold", "SUIT-Medium"].forEach { fontName in
            guard let fontURL = Bundle.main.url(
                forResource: fontName,
                withExtension: "otf",
                subdirectory: nil
            ) else {
                return
            }

            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }

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
        case .titleBold24, .titleBold20, .bodyBold16, .bodyBold14, .bodyBold12,
                .captionBold11, .captionBold10:
            "SUIT-Bold"
        case .titleMedium20, .bodyMedium16, .bodyMedium14, .bodyMedium12,
                .captionMedium11, .captionMedium10:
            "SUIT-Medium"
        }
    }

    private var fontSize: CGFloat {
        switch self {
        case .titleBold24:
            24
        case .titleBold20, .titleMedium20:
            20
        case .bodyBold16, .bodyMedium16:
            16
        case .bodyBold14, .bodyMedium14:
            14
        case .bodyBold12, .bodyMedium12:
            12
        case .captionBold11, .captionMedium11:
            11
        case .captionBold10, .captionMedium10:
            10
        }
    }

    private var lineHeight: CGFloat {
        switch self {
        case .titleBold24:
            31.2
        case .titleBold20, .titleMedium20:
            26
        case .bodyBold16, .bodyMedium16:
            24
        case .bodyBold14, .bodyMedium14:
            21
        case .bodyBold12, .bodyMedium12:
            18
        case .captionBold11, .captionMedium11:
            16.5
        case .captionBold10, .captionMedium10:
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
