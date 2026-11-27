enum CalendarSelectionMode {
    case single
    case range
}

enum CalendarSelection: Equatable {
    case empty
    case single(CalendarDay)
    case range(ClosedRange<CalendarDay>)

    func selecting(_ day: CalendarDay, mode: CalendarSelectionMode) -> CalendarSelection {
        switch mode {
        case .single:
            self == .single(day) ? .empty : .single(day)
        case .range:
            selectingRange(day)
        }
    }

    private func selectingRange(_ day: CalendarDay) -> CalendarSelection {
        switch self {
        case .empty, .range:
            .single(day)
        case .single(let selectedDay):
            day == selectedDay ? .empty : .range(min(selectedDay, day)...max(selectedDay, day))
        }
    }
}
