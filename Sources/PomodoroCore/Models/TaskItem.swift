import Foundation

public struct TaskItem: Identifiable, Codable, Hashable, Equatable, Sendable {
    public var id: UUID
    public var title: String
    public var notes: String
    public var isCompleted: Bool
    public var estimatedPomodoros: Int
    public var completedPomodoros: Int
    public var createdAt: Date
    public var completedAt: Date?
    
    public init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        isCompleted: Bool = false,
        estimatedPomodoros: Int = 1,
        completedPomodoros: Int = 0,
        createdAt: Date = Date(),
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.isCompleted = isCompleted
        self.estimatedPomodoros = max(1, estimatedPomodoros)
        self.completedPomodoros = max(0, completedPomodoros)
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
