import Foundation

public struct AppSettings: Codable, Equatable, Sendable {
    public var focusMinutes: Int
    public var shortBreakMinutes: Int
    public var longBreakMinutes: Int
    public var longBreakInterval: Int
    public var timerMode: TimerMode
    public var dailyGoalCount: Int
    public var soundEnabled: Bool
    public var focusEndSound: String
    public var breakEndSound: String
    public var notificationsEnabled: Bool
    public var progressiveDelaySeconds: Int
    
    public init(
        focusMinutes: Int = 25,
        shortBreakMinutes: Int = 5,
        longBreakMinutes: Int = 15,
        longBreakInterval: Int = 4,
        timerMode: TimerMode = .normal,
        dailyGoalCount: Int = 8,
        soundEnabled: Bool = true,
        focusEndSound: String = "Glass",
        breakEndSound: String = "Hero",
        notificationsEnabled: Bool = true,
        progressiveDelaySeconds: Int = 3
    ) {
        self.focusMinutes = max(1, focusMinutes)
        self.shortBreakMinutes = max(1, shortBreakMinutes)
        self.longBreakMinutes = max(1, longBreakMinutes)
        self.longBreakInterval = max(1, longBreakInterval)
        self.timerMode = timerMode
        self.dailyGoalCount = max(1, dailyGoalCount)
        self.soundEnabled = soundEnabled
        self.focusEndSound = focusEndSound
        self.breakEndSound = breakEndSound
        self.notificationsEnabled = notificationsEnabled
        self.progressiveDelaySeconds = max(0, progressiveDelaySeconds)
    }
}
