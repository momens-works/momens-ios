import Foundation

struct CalendarMonth: Equatable {
    let year: Int
    let month: Int

    func adding(months: Int) -> CalendarMonth {
        let total = year * 12 + (month - 1) + months
        return CalendarMonth(year: total / 12, month: total % 12 + 1)
    }

    var weeks: [[CalendarDay]] {
        guard let firstDate else { return [] }

        let leadingDays = Calendar(identifier: .gregorian).component(.weekday, from: firstDate) - 1
        let dayCount = numberOfDays
        let totalCells = (leadingDays + dayCount + 6) / 7 * 7
        let cells = (0..<totalCells).map { day(at: $0 - leadingDays + 1, dayCount: dayCount) }

        return stride(from: 0, to: totalCells, by: 7).map { Array(cells[$0..<$0 + 7]) }
    }

    func contains(_ day: CalendarDay) -> Bool {
        day.year == year && day.month == month
    }

    private var firstDate: Date? {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: year, month: month, day: 1))
    }

    private var numberOfDays: Int {
        guard let firstDate else { return 0 }
        return Calendar(identifier: .gregorian).range(of: .day, in: .month, for: firstDate)?.count ?? 0
    }

    private func day(at number: Int, dayCount: Int) -> CalendarDay {
        if number < 1 {
            let previous = adding(months: -1)
            return CalendarDay(year: previous.year, month: previous.month, day: previous.numberOfDays + number)
        }
        if number > dayCount {
            let next = adding(months: 1)
            return CalendarDay(year: next.year, month: next.month, day: number - dayCount)
        }
        return CalendarDay(year: year, month: month, day: number)
    }
}
