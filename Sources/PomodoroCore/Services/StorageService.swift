import Foundation

public final class StorageService: @unchecked Sendable {
    public static let shared = StorageService()
    
    private let fileManager = FileManager.default
    private let directoryURL: URL
    private let sessionsURL: URL
    private let tasksURL: URL
    private let settingsURL: URL
    private let queue = DispatchQueue(label: "com.pomodoro.storageservice", qos: .utility)
    
    public init(customDirectory: URL? = nil) {
        if let custom = customDirectory {
            self.directoryURL = custom
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
            self.directoryURL = appSupport.appendingPathComponent("PomodoroClock", isDirectory: true)
        }
        
        self.sessionsURL = directoryURL.appendingPathComponent("sessions.json")
        self.tasksURL = directoryURL.appendingPathComponent("tasks.json")
        self.settingsURL = directoryURL.appendingPathComponent("settings.json")
        
        ensureDirectoryExists()
    }
    
    private func ensureDirectoryExists() {
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Sessions
    
    public func loadSessions() -> [PomodoroSession] {
        guard let data = try? Data(contentsOf: sessionsURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([PomodoroSession].self, from: data)) ?? []
    }
    
    public func saveSessions(_ sessions: [PomodoroSession]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(sessions) {
                try? data.write(to: self.sessionsURL, options: .atomic)
            }
        }
    }
    
    // MARK: - Tasks
    
    public func loadTasks() -> [TaskItem] {
        guard let data = try? Data(contentsOf: tasksURL) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([TaskItem].self, from: data)) ?? []
    }
    
    public func saveTasks(_ tasks: [TaskItem]) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            if let data = try? encoder.encode(tasks) {
                try? data.write(to: self.tasksURL, options: .atomic)
            }
        }
    }
    
    // MARK: - Settings
    
    public func loadSettings() -> AppSettings {
        guard let data = try? Data(contentsOf: settingsURL) else { return AppSettings() }
        let decoder = JSONDecoder()
        return (try? decoder.decode(AppSettings.self, from: data)) ?? AppSettings()
    }
    
    public func saveSettings(_ settings: AppSettings) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(settings) {
                try? data.write(to: self.settingsURL, options: .atomic)
            }
        }
    }
    
    public var storageDirectoryPath: String {
        directoryURL.path
    }
}
