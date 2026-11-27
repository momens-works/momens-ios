import SwiftUI

struct MomensCalendar: View {
    let month: CalendarMonth
    let selectionMode: CalendarSelectionMode
    let selection: CalendarSelection
    let onSelectionChange: (CalendarSelection) -> Void
    let onMonthChange: (CalendarMonth) -> Void
    var today = CalendarDay.today
    var disabledDays: Set<CalendarDay> = []
    var originalDay: CalendarDay?

    var body: some View {
        VStack(spacing: 0) {
            CalendarMonthHeader(month: month, onMonthChange: onMonthChange)

            Rectangle()
                .fill(MomensColor.gray200)
                .frame(height: 1)
                .padding(.horizontal, 10)
                .padding(.top, 4)

            CalendarWeekdayHeader()
                .padding(.top, 3)

            dateGrid
                .padding(.horizontal, 13)
                .padding(.top, 4)
        }
        .background(MomensColor.white)
    }

    private var dateGrid: some View {
        VStack(spacing: 0) {
            ForEach(Array(month.weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                dateCell(for: day)
                            }
                    }
                }
            }
        }
    }

    private func dateCell(for day: CalendarDay) -> some View {
        CalendarDateCell(
            day: day,
            state: CalendarDateState(
                day: day,
                isInMonth: month.contains(day),
                selection: selection,
                disabledDays: disabledDays,
                today: today,
                originalDay: originalDay
            ),
            action: { onSelectionChange(selection.selecting(day, mode: selectionMode)) }
        )
    }
}

private struct CalendarMonthHeader: View {
    let month: CalendarMonth
    let onMonthChange: (CalendarMonth) -> Void

    private var title: String {
        "\(month.year)년 \(month.month)월"
    }

    var body: some View {
        HStack(spacing: 0) {
            arrowButton(label: "이전 달", months: -1)

            Text(title)
                .momensFont(.bodyB14)
                .foregroundStyle(MomensColor.gray900)
                .frame(maxWidth: .infinity)

            arrowButton(label: "다음 달", months: 1)
        }
        .frame(height: 48)
        .padding(.horizontal, 10)
    }

    private func arrowButton(label: String, months: Int) -> some View {
        Button {
            onMonthChange(month.adding(months: months))
        } label: {
            Image("ic_next")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .scaleEffect(x: months < 0 ? -1 : 1)
                .foregroundStyle(MomensColor.black)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

private struct CalendarWeekdayHeader: View {
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .momensFont(.captionM10)
                    .foregroundStyle(color(for: weekday))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 13)
    }

    private func color(for weekday: String) -> Color {
        switch weekday {
        case "일":
            MomensColor.pointRed
        case "토":
            MomensColor.primary50
        default:
            MomensColor.black
        }
    }
}

private struct CalendarDateCell: View {
    let day: CalendarDay
    let state: CalendarDateState
    let action: () -> Void

    private var accessibilityTitle: String {
        "\(day.month)월 \(day.day)일"
    }

    var body: some View {
        if state == .outsideMonth {
            dayLabel
                .accessibilityHidden(true)
        } else if state == .disabled {
            dayLabel
                .accessibilityLabel(accessibilityTitle)
                .accessibilityValue("선택 불가")
        } else {
            Button(action: action) {
                dayLabel
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityTitle)
            .accessibilityAddTraits(state.isSelected ? .isSelected : [])
        }
    }

    private var dayLabel: some View {
        Text(String(day.day))
            .momensFont(.bodyM14)
            .foregroundStyle(state.textColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(state.backgroundColor, in: state.shape)
            .contentShape(.rect)
    }
}

private struct MomensCalendarPreview: View {
    @State private var month = CalendarMonth(year: 2026, month: 10)
    @State private var selection: CalendarSelection

    private let selectionMode: CalendarSelectionMode
    private let today: CalendarDay
    private let originalDay: CalendarDay?

    init(
        selectionMode: CalendarSelectionMode,
        selection: CalendarSelection,
        today: CalendarDay,
        originalDay: CalendarDay? = nil
    ) {
        _selection = State(initialValue: selection)
        self.selectionMode = selectionMode
        self.today = today
        self.originalDay = originalDay
    }

    var body: some View {
        MomensCalendar(
            month: month,
            selectionMode: selectionMode,
            selection: selection,
            onSelectionChange: { selection = $0 },
            onMonthChange: { month = $0 },
            today: today,
            originalDay: originalDay
        )
        .frame(width: 320)
        .padding(16)
        .background(MomensColor.gray200)
    }
}

#Preview("MomensCalendar - Due date filter") {
    MomensCalendarPreview(
        selectionMode: .range,
        selection: .empty,
        today: CalendarDay(year: 2026, month: 10, day: 13)
    )
}

#Preview("MomensCalendar - Task creation") {
    MomensCalendarPreview(
        selectionMode: .single,
        selection: .single(CalendarDay(year: 2026, month: 10, day: 13)),
        today: CalendarDay(year: 2026, month: 10, day: 13)
    )
}

#Preview("MomensCalendar - Due date edit") {
    MomensCalendarPreview(
        selectionMode: .single,
        selection: .single(CalendarDay(year: 2026, month: 10, day: 13)),
        today: CalendarDay(year: 2026, month: 10, day: 1),
        originalDay: CalendarDay(year: 2026, month: 10, day: 9)
    )
}
