import SwiftUI

public struct DailyProgressView: View {
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    let dailyGoal: Int
    
    @ViewState private var showingManualEntrySheet = false
    
    public init(
        progressViewModel: ProgressViewModel,
        taskViewModel: TaskViewModel,
        dailyGoal: Int = 8
    ) {
        self.progressViewModel = progressViewModel
        self.taskViewModel = taskViewModel
        self.dailyGoal = dailyGoal
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Daily Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Today, \(Date().formattedDate)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Manual '+' Button
                Button {
                    showingManualEntrySheet = true
                } label: {
                    Label("Log Unrecorded Session", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding([.top, .horizontal])
            
            // Stats Row
            HStack(spacing: 16) {
                // Focus Sessions Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("Completed Focus")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(progressViewModel.todayFocusCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.red)
                        Text("/ \(dailyGoal) goal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    ProgressView(value: progressViewModel.goalProgress(goal: dailyGoal))
                        .tint(.red)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
                // Focus Time Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Focus Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(progressViewModel.todayFocusFormattedTime)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Productive time today")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
                
                // Total Sessions Card
                VStack(alignment: .leading, spacing: 6) {
                    Text("All Sessions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(progressViewModel.todaySessions.count)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("\(progressViewModel.todaySessions.filter { $0.sessionType.isBreak }.count) breaks taken")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .controlBackgroundColor))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Quick Session Count Adjuster Card
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quick Adjust Today's Session Count")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Directly increment or decrement today's completed session tally")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        progressViewModel.adjustTodayCount(by: -1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .disabled(progressViewModel.todayFocusCount <= 0)
                    .help("Decrement session count")
                    
                    Text("\(progressViewModel.todayFocusCount)")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .frame(minWidth: 32)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        progressViewModel.adjustTodayCount(by: 1)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Increment session count")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.8))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Divider()
            
            // Session Timeline Header
            HStack {
                Text("Today's Sessions Timeline")
                    .font(.headline)
                Spacer()
                Text("\(progressViewModel.todaySessions.count) entries")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Sessions List
            if progressViewModel.todaySessions.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "clock.badge.checkmark")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("No sessions recorded yet today")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Complete a timer session or click \"Log Unrecorded Session\" above.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(progressViewModel.todaySessions) { session in
                        SessionHistoryRow(session: session) {
                            progressViewModel.deleteSession(session)
                        }
                        .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(isPresented: $showingManualEntrySheet) {
            ManualEntrySheet(tasks: taskViewModel.tasks) { type, duration, date, taskName, notes in
                progressViewModel.addManualSession(
                    type: type,
                    durationMinutes: duration,
                    date: date,
                    taskName: taskName,
                    notes: notes
                )
            }
        }
    }
}
