import Foundation

public struct PomodoroSession: Identifiable, Codable, Hashable, Equatable, Sendable {
    public var id: UUID
    public var timestamp: Date
    public var sessionType: SessionType
    public var durationMinutes: Int
    public var taskName: String?
    public var taskId: UUID?
    public var mode: TimerMode
    public var isManual: Bool
    public var notes: String?
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        sessionType: SessionType = .focus,
        durationMinutes: Int = 25,
        taskName: String? = nil,
        taskId: UUID? = nil,
        mode: TimerMode = .normal,
        isManual: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.sessionType = sessionType
        self.durationMinutes = max(1, durationMinutes)
        self.taskName = taskName
        self.taskId = taskId
        self.mode = mode
        self.isManual = isManual
        self.notes = notes
    }
}
