import SwiftUI

enum MomensButtonType {
    case primary
    case gray
    case black
    case white

    var typography: MomensTypography {
        switch self {
        case .primary:
            .bodyB12
        case .gray, .black, .white:
            .bodyM12
        }
    }

    var textColor: Color {
        switch self {
        case .primary, .black:
            MomensColor.white
        case .gray:
            MomensColor.gray700
        case .white:
            MomensColor.gray500
        }
    }

    var backgroundColor: Color {
        switch self {
        case .primary:
            MomensColor.primary50
        case .gray:
            MomensColor.gray100
        case .black:
            MomensColor.gray800
        case .white:
            MomensColor.white
        }
    }
}
