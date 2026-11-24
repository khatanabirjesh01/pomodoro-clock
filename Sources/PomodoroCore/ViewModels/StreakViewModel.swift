import Foundation
import Combine

public struct CalendarDayItem: Identifiable, Equatable {
    public var id: String { "\(date.timeIntervalSince1970)" }
    public let date: Date
    public let dayNumber: Int
    public let isCurrentMonth: Bool
    public let isToday: Bool
    public let focusCount: Int
    public let breakCount: Int
    
    public var hasSessions: Bool {
        focusCount > 0
    }
}

@MainActor
public final class StreakViewModel: ObservableObject {
    @Published public var displayedMonth: Date = Date()
    @Published public var selectedDate: Date = Date()
    
    public init() {}
    
    // MARK: - Navigation
    
    public func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    public func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newDate
        }
    }
    
    public func goToToday() {
        let now = Date()
        displayedMonth = now
        selectedDate = now
    }
    
    // MARK: - Streak Calculations
    
    public func calculateCurrentStreak(sessions: [PomodoroSession]) -> Int {
        let calendar = Calendar.current
        let focusSessions = sessions.filter { $0.sessionType == .focus }
        guard !focusSessions.isEmpty else { return 0 }
        
        let sessionDates = Set(focusSessions.map { calendar.startOfDay(for: $0.timestamp) })
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var checkDate = today
        
        // If today has sessions, start counting from today
        if sessionDates.contains(today) {
            while sessionDates.contains(checkDate) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            }
        } else {
            // If today doesn't have sessions yet, check if yesterday did
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  sessionDates.contains(yesterday) else {
                return 0
            }
            checkDate = yesterday
            while sessionDates.contains(checkDate) {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            }
        }
        
        return streak
    }
    
    public func calculateLongestStreak(sessions: [PomodoroSession]) -> Int {
        let calendar = Calendar.current
        let focusSessions = sessions.filter { $0.sessionType == .focus }
        guard !focusSessions.isEmpty else { return 0 }
        
        let uniqueDays = Array(Set(focusSessions.map { calendar.startOfDay(for: $0.timestamp) })).sorted()
        guard !uniqueDays.isEmpty else { return 0 }
        
        var longest = 1
        var current = 1
        
        for i in 1..<uniqueDays.count {
            let prevDay = uniqueDays[i - 1]
            let day = uniqueDays[i]
            
            if let expectedNext = calendar.date(byAdding: .day, value: 1, to: prevDay),
               calendar.isDate(day, inSameDayAs: expectedNext) {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        
        return longest
    }
    
    public func totalFocusHours(sessions: [PomodoroSession]) -> Double {
        let minutes = sessions.filter { $0.sessionType == .focus }.reduce(0) { $0 + $1.durationMinutes }
        return Double(minutes) / 60.0
    }
    
    // MARK: - Calendar Grid Generation
    
    public func generateDaysForDisplayedMonth(sessions: [PomodoroSession]) -> [CalendarDayItem] {
        let calendar = Calendar.current
        
        // Find start of month
        let components = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let startOfMonth = calendar.date(from: components),
              let monthRange = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Group sessions by day
        var sessionCounts: [Date: (focus: Int, breaks: Int)] = [:]
        for s in sessions {
            let day = calendar.startOfDay(for: s.timestamp)
            var current = sessionCounts[day] ?? (0, 0)
            if s.sessionType == .focus {
                current.focus += 1
            } else {
                current.breaks += 1
            }
            sessionCounts[day] = current
        }
        
        var days: [CalendarDayItem] = []
        
        // Find weekday of the first day of month (1 = Sunday in Gregorian default)
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let leadingDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        // Leading days from previous month
        if leadingDays > 0 {
            for dayOffset in stride(from: leadingDays, to: 0, by: -1) {
                if let date = calendar.date(byAdding: .day, value: -dayOffset, to: startOfMonth) {
                    let dayNum = calendar.component(.day, from: date)
                    let dayStart = calendar.startOfDay(for: date)
                    let counts = sessionCounts[dayStart] ?? (0, 0)
                    days.append(CalendarDayItem(
                        date: date,
                        dayNumber: dayNum,
                        isCurrentMonth: false,
                        isToday: calendar.isDateInToday(date),
                        focusCount: counts.focus,
                        breakCount: counts.breaks
                    ))
                }
            }
        }
        
        // Days of current month
        for day in monthRange {
            var dayComp = components
            dayComp.day = day
            if let date = calendar.date(from: dayComp) {
                let dayStart = calendar.startOfDay(for: date)
                let counts = sessionCounts[dayStart] ?? (0, 0)
                days.append(CalendarDayItem(
                    date: date,
                    dayNumber: day,
                    isCurrentMonth: true,
                    isToday: calendar.isDateInToday(date),
                    focusCount: counts.focus,
                    breakCount: counts.breaks
                ))
            }
        }
        
        // Trailing days from next month to complete row of 7
        let trailingDays = (7 - (days.count % 7)) % 7
        if trailingDays > 0, let lastDate = days.last?.date {
            for dayOffset in 1...trailingDays {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: lastDate) {
                    let dayNum = calendar.component(.day, from: date)
                    let dayStart = calendar.startOfDay(for: date)
                    let counts = sessionCounts[dayStart] ?? (0, 0)
                    days.append(CalendarDayItem(
                        date: date,
                        dayNumber: dayNum,
                        isCurrentMonth: false,
                        isToday: calendar.isDateInToday(date),
                        focusCount: counts.focus,
                        breakCount: counts.breaks
                    ))
                }
            }
        }
        
        return days
    }
}
