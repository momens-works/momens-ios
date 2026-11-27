import Foundation

nonisolated struct CalendarDay: Hashable, Comparable {
    let year: Int
    let month: Int
    let day: Int

    static var today: CalendarDay {
        let components = Calendar(identifier: .gregorian).dateComponents([.year, .month, .day], from: Date())
        return CalendarDay(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0
        )
    }

    static func < (lhs: CalendarDay, rhs: CalendarDay) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
