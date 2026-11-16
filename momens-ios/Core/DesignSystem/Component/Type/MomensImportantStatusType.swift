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

enum MomensImportantStatusStyle: CaseIterable, Hashable {
    case unselected
    case selected
    case taskList

    var backgroundColor: Color {
        switch self {
        case .unselected:
            MomensColor.gray100
        case .selected:
            MomensColor.primary50
        case .taskList:
            Color.clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .unselected:
            MomensColor.gray700
        case .selected:
            MomensColor.primary10
        case .taskList:
            MomensColor.gray600
        }
    }

    var typography: MomensTypography {
        self == .selected ? .bodyB12 : .bodyM12
    }

    var iconColor: String {
        self == .selected ? "blue" : "gray"
    }

    var isBadge: Bool {
        self != .taskList
    }
}
