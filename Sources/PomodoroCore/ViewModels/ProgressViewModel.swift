import Foundation
import Combine

@MainActor
public final class ProgressViewModel: ObservableObject {
    @Published public var sessions: [PomodoroSession] = []
    
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
        self.sessions = storage.loadSessions()
    }
    
    // MARK: - Today's Progress Calculations
    
    public var todaySessions: [PomodoroSession] {
        let today = Date()
        return sessions
            .filter { $0.timestamp.isSameDay(as: today) }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    public var todayFocusSessions: [PomodoroSession] {
        todaySessions.filter { $0.sessionType == .focus }
    }
    
    public var todayFocusCount: Int {
        todayFocusSessions.count
    }
    
    public var todayFocusMinutes: Int {
        todayFocusSessions.reduce(0) { $0 + $1.durationMinutes }
    }
    
    public var todayFocusFormattedTime: String {
        let minutes = todayFocusMinutes
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    public func goalProgress(goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(todayFocusCount) / Double(goal))
    }
    
    // MARK: - Logging & Modification
    
    @discardableResult
    public func recordSession(
        type: SessionType,
        durationMinutes: Int,
        taskName: String?,
        taskId: UUID?,
        mode: TimerMode,
        isManual: Bool = false,
        timestamp: Date = Date(),
        notes: String? = nil
    ) -> PomodoroSession {
        let session = PomodoroSession(
            id: UUID(),
            timestamp: timestamp,
            sessionType: type,
            durationMinutes: durationMinutes,
            taskName: taskName,
            taskId: taskId,
            mode: mode,
            isManual: isManual,
            notes: notes
        )
        sessions.append(session)
        storage.saveSessions(sessions)
        return session
    }
    
    public func addManualSession(
        type: SessionType,
        durationMinutes: Int,
        date: Date,
        taskName: String?,
        notes: String? = nil
    ) {
        recordSession(
            type: type,
            durationMinutes: durationMinutes,
            taskName: taskName?.isEmpty == true ? nil : taskName,
            taskId: nil,
            mode: .normal,
            isManual: true,
            timestamp: date,
            notes: notes
        )
    }
    
    /// Adjusts today's focus session count directly (manual adjustment requested in prompt)
    public func adjustTodayCount(by delta: Int, defaultDuration: Int = 25) {
        if delta > 0 {
            for _ in 0..<delta {
                addManualSession(
                    type: .focus,
                    durationMinutes: defaultDuration,
                    date: Date(),
                    taskName: "Manual Entry",
                    notes: "Quick tally adjustment"
                )
            }
        } else if delta < 0 {
            let removalsCount = abs(delta)
            var removed = 0
            // Prioritize removing manual sessions first, then most recent today's focus sessions
            for i in stride(from: sessions.count - 1, through: 0, by: -1) {
                if removed >= removalsCount { break }
                let s = sessions[i]
                if s.timestamp.isSameDay(as: Date()) && s.sessionType == .focus {
                    sessions.remove(at: i)
                    removed += 1
                }
            }
            storage.saveSessions(sessions)
        }
    }
    
    public func deleteSession(_ session: PomodoroSession) {
        sessions.removeAll(where: { $0.id == session.id })
        storage.saveSessions(sessions)
    }
    
    // MARK: - Query by Date
    
    public func sessions(for date: Date) -> [PomodoroSession] {
        sessions
            .filter { $0.timestamp.isSameDay(as: date) }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    public func focusCount(for date: Date) -> Int {
        sessions(for: date).filter { $0.sessionType == .focus }.count
    }
}
