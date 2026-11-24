import SwiftUI

public struct SessionHistoryRow: View {
    let session: PomodoroSession
    let onDelete: () -> Void
    
    public init(session: PomodoroSession, onDelete: @escaping () -> Void) {
        self.session = session
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accent(for: session.sessionType).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: session.sessionType.iconName)
                    .foregroundStyle(Color.accent(for: session.sessionType))
                    .font(.system(size: 14))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(session.sessionType.rawValue)
                        .font(.system(size: 13, weight: .semibold))
                    
                    if session.isManual {
                        Text("Manual")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Color.orange.opacity(0.18)))
                            .foregroundStyle(.orange)
                    }
                    
                    if session.mode == .progressive {
                        Text("Progressive")
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(Capsule().fill(Color.purple.opacity(0.18)))
                            .foregroundStyle(.purple)
                    }
                }
                
                if let task = session.taskName, !task.isEmpty {
                    Text(task)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Duration & Time
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.durationMinutes) min")
                    .font(.system(size: 13, weight: .medium))
                Text(session.timestamp.formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            // Delete button
            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Delete session log")
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
    }
}
