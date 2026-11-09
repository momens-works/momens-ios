import SwiftUI

enum MomensButtonType {
    case primary
    case gray
    case black
    case white

    func typography(isDropdown: Bool) -> MomensTypography {
        switch self {
        case .primary:
            isDropdown ? .bodyM12 : .bodyB12
        case .gray, .black, .white:
            .bodyM12
        }
    }

    func textColor(isDropdown: Bool) -> Color {
        switch self {
        case .primary, .black:
            MomensColor.white
        case .gray:
            MomensColor.gray700
        case .white:
            isDropdown ? MomensColor.gray800 : MomensColor.gray500
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
