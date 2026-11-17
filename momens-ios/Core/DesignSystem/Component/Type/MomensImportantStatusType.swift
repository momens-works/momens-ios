import DeveloperToolsSupport
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

    func iconAsset(isSelected: Bool) -> ImageResource {
        switch (self, isSelected) {
        case (.low, false): .icImportanceLowGray
        case (.low, true): .icImportanceLowBlue
        case (.medium, false): .icImportanceMediumGray
        case (.medium, true): .icImportanceMediumBlue
        case (.high, false), (.urgent, false): .icImportanceHighGray
        case (.high, true), (.urgent, true): .icImportanceHighBlue
        }
    }
}

enum MomensImportantStatusStyle: CaseIterable, Hashable {
    case unselected
    case selected
    case whiteBadge
    case taskList

    var backgroundColor: Color {
        switch self {
        case .unselected:
            MomensColor.gray100
        case .selected:
            MomensColor.primary50
        case .whiteBadge:
            MomensColor.white
        case .taskList:
            Color.clear
        }
    }

    var foregroundColor: Color {
        switch self {
        case .unselected, .whiteBadge:
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

    var isBadge: Bool {
        self != .taskList
    }
}
