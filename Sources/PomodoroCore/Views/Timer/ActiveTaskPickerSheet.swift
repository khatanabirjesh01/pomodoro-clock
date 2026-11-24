import SwiftUI

public struct ActiveTaskPickerSheet: View {
    @ObservedObject var taskViewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @ViewState private var newQuickTaskTitle = ""
    
    public init(taskViewModel: TaskViewModel) {
        self.taskViewModel = taskViewModel
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Select Active Task")
                    .font(.headline)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding([.top, .horizontal])
            
            // Quick add field
            HStack {
                TextField("Quickly add new task...", text: $newQuickTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        quickAdd()
                    }
                Button {
                    quickAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .disabled(newQuickTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            
            Divider()
            
            List {
                // Clear active task option
                Button {
                    taskViewModel.setActiveTask(nil)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "slash.circle")
                            .foregroundStyle(.secondary)
                        Text("No active task (General Focus)")
                            .foregroundStyle(.primary)
                        Spacer()
                        if taskViewModel.activeTaskId == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                Section("Uncompleted Tasks") {
                    let activeTasks = taskViewModel.tasks.filter { !$0.isCompleted }
                    if activeTasks.isEmpty {
                        Text("No active tasks. Add one above!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(activeTasks) { task in
                            Button {
                                taskViewModel.setActiveTask(task)
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "target")
                                        .foregroundStyle(taskViewModel.activeTaskId == task.id ? .red : .secondary)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        HStack(spacing: 6) {
                                            Text("🍅 \(task.completedPomodoros)/\(task.estimatedPomodoros)")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            if !task.notes.isEmpty {
                                                Text("• \(task.notes)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    Spacer()
                                    if taskViewModel.activeTaskId == task.id {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.blue)
                                            .fontWeight(.bold)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .listStyle(.inset)
        }
        .frame(width: 420, height: 420)
    }
    
    private func quickAdd() {
        let trimmed = newQuickTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        taskViewModel.addTask(title: trimmed)
        newQuickTaskTitle = ""
        dismiss()
    }
}
