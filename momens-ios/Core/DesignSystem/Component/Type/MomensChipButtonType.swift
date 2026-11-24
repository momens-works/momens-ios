import SwiftUI

enum MomensChipButtonType {
    case white
    case black
    case purple
    case red
    case yellow
    case mint

    var textColor: Color {
        switch self {
        case .white:
            MomensColor.gray800
        case .black, .purple, .red, .yellow, .mint:
            MomensColor.white
        }
    }

    var backgroundColor: Color {
        switch self {
        case .white:
            MomensColor.white
        case .black:
            MomensColor.gray800
        case .purple:
            MomensColor.pointPurple
        case .red:
            MomensColor.pointRed
        case .yellow:
            MomensColor.pointYellow
        case .mint:
            MomensColor.pointMint
        }
    }
}
