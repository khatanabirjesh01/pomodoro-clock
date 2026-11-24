import SwiftUI

public struct DayDetailsView: View {
    let date: Date
    let sessions: [PomodoroSession]
    let onDeleteSession: (PomodoroSession) -> Void
    
    public init(
        date: Date,
        sessions: [PomodoroSession],
        onDeleteSession: @escaping (PomodoroSession) -> Void
    ) {
        self.date = date
        self.sessions = sessions
        self.onDeleteSession = onDeleteSession
    }
    
    private var totalFocusMinutes: Int {
        sessions.filter { $0.sessionType == .focus }.reduce(0) { $0 + $1.durationMinutes }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formattedDate)
                        .font(.headline)
                    Text("\(sessions.filter { $0.sessionType == .focus }.count) focus sessions • \(totalFocusMinutes) minutes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            if sessions.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary.opacity(0.4))
                    Text("No sessions on this day")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 120)
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(sessions) { session in
                            SessionHistoryRow(session: session) {
                                onDeleteSession(session)
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxHeight: 180)
            }
        }
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
