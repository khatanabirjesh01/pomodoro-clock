import SwiftUI

public struct StreakCalendarView: View {
    @ObservedObject var streakViewModel: StreakViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols
    
    public init(streakViewModel: StreakViewModel, progressViewModel: ProgressViewModel) {
        self.streakViewModel = streakViewModel
        self.progressViewModel = progressViewModel
    }
    
    public var body: some View {
        let currentStreak = streakViewModel.calculateCurrentStreak(sessions: progressViewModel.sessions)
        let longestStreak = streakViewModel.calculateLongestStreak(sessions: progressViewModel.sessions)
        let totalHours = streakViewModel.totalFocusHours(sessions: progressViewModel.sessions)
        let totalFocusSessions = progressViewModel.sessions.filter { $0.sessionType == .focus }.count
        let calendarDays = streakViewModel.generateDaysForDisplayedMonth(sessions: progressViewModel.sessions)
        let selectedDaySessions = progressViewModel.sessions(for: streakViewModel.selectedDate)
        
        ScrollView {
            VStack(spacing: 20) {
                // Streak & All-Time Stats Cards
                HStack(spacing: 14) {
                    // Current Streak Card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("Current Streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(currentStreak)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.orange)
                            Text(currentStreak == 1 ? "day" : "days")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(currentStreak > 0 ? "Keep the fire burning!" : "Complete a focus session today!")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Longest Streak Card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundStyle(.yellow)
                            Text("Best Streak")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(longestStreak)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.primary)
                            Text(longestStreak == 1 ? "day" : "days")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text("Personal best record")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                    
                    // Total Focus All-Time Card
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundStyle(.blue)
                            Text("Total Focus Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%.1f", totalHours))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("hrs")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(totalFocusSessions) sessions completed")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }
                .padding([.top, .horizontal])
                
                // Calendar Container
                VStack(spacing: 12) {
                    // Month Navigation Header
                    HStack {
                        Button {
                            streakViewModel.previousMonth()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        
                        Text(streakViewModel.displayedMonth.monthYearString)
                            .font(.headline)
                            .frame(minWidth: 160)
                        
                        Button {
                            streakViewModel.nextMonth()
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 8)
                        
                        Spacer()
                        
                        Button("Today") {
                            streakViewModel.goToToday()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .padding(.horizontal)
                    
                    // Weekday Labels
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(weekdaySymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Calendar Day Grid
                    LazyVGrid(columns: columns, spacing: 4) {
                        ForEach(calendarDays) { day in
                            CalendarDayCell(
                                dayItem: day,
                                isSelected: streakViewModel.selectedDate.isSameDay(as: day.date)
                            ) {
                                streakViewModel.selectedDate = day.date
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Selected Day Details
                DayDetailsView(
                    date: streakViewModel.selectedDate,
                    sessions: selectedDaySessions,
                    onDeleteSession: { session in
                        progressViewModel.deleteSession(session)
                    }
                )
            }
            .padding(.bottom, 20)
        }
    }
}
