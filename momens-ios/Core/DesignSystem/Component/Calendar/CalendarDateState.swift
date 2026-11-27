import SwiftUI

enum CalendarDateState: Equatable {
    case normal
    case today
    case selected
    case original
    case disabled
    case outsideMonth
    case rangeStart
    case rangeMiddle
    case rangeEnd

    init(
        day: CalendarDay,
        isInMonth: Bool,
        selection: CalendarSelection,
        disabledDays: Set<CalendarDay>,
        today: CalendarDay,
        originalDay: CalendarDay?
    ) {
        if !isInMonth {
            self = .outsideMonth
        } else if disabledDays.contains(day) {
            self = .disabled
        } else if let selectedState = Self.selectionState(of: day, in: selection) {
            self = selectedState
        } else if day == originalDay {
            self = .original
        } else {
            self = day == today ? .today : .normal
        }
    }

    var isSelected: Bool {
        switch self {
        case .selected, .rangeStart, .rangeMiddle, .rangeEnd:
            true
        case .normal, .today, .original, .disabled, .outsideMonth:
            false
        }
    }

    var textColor: Color {
        switch self {
        case .selected, .original, .rangeStart, .rangeEnd:
            MomensColor.white
        case .today, .rangeMiddle:
            MomensColor.primary100
        case .disabled, .outsideMonth:
            MomensColor.black.opacity(0.4)
        case .normal:
            MomensColor.black
        }
    }

    var backgroundColor: Color {
        switch self {
        case .selected, .rangeStart, .rangeEnd:
            MomensColor.primary100
        case .rangeMiddle:
            MomensColor.primary10
        case .original:
            MomensColor.gray200
        case .normal, .today, .disabled, .outsideMonth:
            .clear
        }
    }

    var shape: UnevenRoundedRectangle {
        let radius: CGFloat = 10
        let leading = [.selected, .original, .rangeStart].contains(self) ? radius : 0
        let trailing = [.selected, .original, .rangeEnd].contains(self) ? radius : 0

        return UnevenRoundedRectangle(
            topLeadingRadius: leading,
            bottomLeadingRadius: leading,
            bottomTrailingRadius: trailing,
            topTrailingRadius: trailing
        )
    }

    private static func selectionState(of day: CalendarDay, in selection: CalendarSelection) -> CalendarDateState? {
        switch selection {
        case .empty:
            return nil
        case .single(let selectedDay):
            return day == selectedDay ? .selected : nil
        case .range(let range):
            guard range.contains(day) else { return nil }
            if range.lowerBound == range.upperBound { return .selected }
            if day == range.lowerBound { return .rangeStart }
            if day == range.upperBound { return .rangeEnd }
            return .rangeMiddle
        }
    }
}
