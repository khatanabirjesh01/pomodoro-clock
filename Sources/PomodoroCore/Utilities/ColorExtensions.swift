import SwiftUI

public extension Color {
    static let focusAccent = Color.red
    static let shortBreakAccent = Color.teal
    static let longBreakAccent = Color.blue
    static let streakAccent = Color.orange
    
    static func accent(for sessionType: SessionType) -> Color {
        switch sessionType {
        case .focus:
            return .focusAccent
        case .shortBreak:
            return .shortBreakAccent
        case .longBreak:
            return .longBreakAccent
        }
    }
}
