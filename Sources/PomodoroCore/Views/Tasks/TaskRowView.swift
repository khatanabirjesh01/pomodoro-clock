import SwiftUI

public struct TaskRowView: View {
    let task: TaskItem
    let isActive: Bool
    let onToggleComplete: () -> Void
    let onSetActive: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    public init(
        task: TaskItem,
        isActive: Bool,
        onToggleComplete: @escaping () -> Void,
        onSetActive: @escaping () -> Void,
        onEdit: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.task = task
        self.isActive = isActive
        self.onToggleComplete = onToggleComplete
        self.onSetActive = onSetActive
        self.onEdit = onEdit
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Checkbox
            Button {
                onToggleComplete()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(task.title)
                    .font(.system(size: 14, weight: .medium))
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    // Pomodoro count badge
                    Label("\(task.completedPomodoros)/\(task.estimatedPomodoros)", systemImage: "timer")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.red.opacity(0.12)))
                        .foregroundStyle(.red)
                    
                    if !task.notes.isEmpty {
                        Text(task.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Active target indicator/button
            if !task.isCompleted {
                Button {
                    onSetActive()
                } label: {
                    Image(systemName: isActive ? "target" : "circle.dotted")
                        .font(.system(size: 16))
                        .foregroundStyle(isActive ? .red : .secondary)
                }
                .buttonStyle(.plain)
                .help(isActive ? "Current active timer task" : "Set as active timer task")
            }
            
            // Edit button
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Edit Task")
            
            // Delete button
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("Delete Task")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isActive ? Color.red.opacity(0.06) : Color.clear)
        )
    }
}
