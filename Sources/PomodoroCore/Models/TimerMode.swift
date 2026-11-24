import Foundation

public enum TimerMode: String, Codable, CaseIterable, Identifiable, Sendable {
    case normal = "Normal"
    case progressive = "Progressive"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .normal:
            return "Stops at 00:00 and waits for you to start the next session."
        case .progressive:
            return "Automatically logs the completed session and transitions into the next phase."
        }
    }
    
    public var iconName: String {
        switch self {
        case .normal:
            return "pause.circle.fill"
        case .progressive:
            return "bolt.horizontal.circle.fill"
        }
    }
}
