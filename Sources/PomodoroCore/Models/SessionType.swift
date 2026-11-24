import Foundation

public enum SessionType: String, Codable, CaseIterable, Identifiable, Sendable {
    case focus = "Focus"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .focus:
            return "flame.fill"
        case .shortBreak:
            return "cup.and.saucer.fill"
        case .longBreak:
            return "leaf.fill"
        }
    }
    
    public var isBreak: Bool {
        self != .focus
    }
}
