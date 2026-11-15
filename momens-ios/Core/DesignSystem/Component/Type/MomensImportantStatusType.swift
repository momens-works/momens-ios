import SwiftUI

enum MomensImportantStatusLevel: String, CaseIterable, Hashable {
    case low
    case medium
    case high
    case urgent

    var title: String {
        switch self {
        case .low:
            "낮음"
        case .medium:
            "중간"
        case .high:
            "높음"
        case .urgent:
            "긴급"
        }
    }

    var iconAssetLevel: String {
        self == .urgent ? MomensImportantStatusLevel.high.rawValue : rawValue
    }
}

enum MomensImportantStatusColorStyle: CaseIterable, Hashable {
    case gray
    case blue

    var backgroundColor: Color {
        switch self {
        case .gray:
            MomensColor.gray100
        case .blue:
            MomensColor.primary50
        }
    }

    var foregroundColor: Color {
        self == .blue ? MomensColor.primary10 : MomensColor.gray700
    }

    var typography: MomensTypography {
        self == .blue ? .bodyB12 : .bodyM12
    }

    var iconColor: String {
        self == .blue ? "blue" : "gray"
    }
}
