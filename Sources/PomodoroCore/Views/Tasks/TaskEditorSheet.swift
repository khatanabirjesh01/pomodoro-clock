import SwiftUI

public struct TaskEditorSheet: View {
    let taskToEdit: TaskItem?
    let onSave: (String, String, Int, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @ViewState private var title: String = ""
    @ViewState private var notes: String = ""
    @ViewState private var estimatedPomodoros: Int = 1
    @ViewState private var completedPomodoros: Int = 0
    
    public init(taskToEdit: TaskItem? = nil, onSave: @escaping (String, String, Int, Int) -> Void) {
        self.taskToEdit = taskToEdit
        self.onSave = onSave
        _title = ViewState(initialValue: taskToEdit?.title ?? "")
        _notes = ViewState(initialValue: taskToEdit?.notes ?? "")
        _estimatedPomodoros = ViewState(initialValue: taskToEdit?.estimatedPomodoros ?? 1)
        _completedPomodoros = ViewState(initialValue: taskToEdit?.completedPomodoros ?? 0)
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(taskToEdit == nil ? "New Task" : "Edit Task")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    save()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding([.top, .horizontal])
            
            Form {
                TextField("Task Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Notes (optional)", text: $notes, axis: .vertical)
                    .lineLimit(3...5)
                    .textFieldStyle(.roundedBorder)
                
                Stepper("Estimated Pomodoros: \(estimatedPomodoros)", value: $estimatedPomodoros, in: 1...30)
                
                if taskToEdit != nil {
                    Stepper("Completed Pomodoros: \(completedPomodoros)", value: $completedPomodoros, in: 0...50)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 400, height: 280)
    }
    
    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSave(trimmed, notes.trimmingCharacters(in: .whitespacesAndNewlines), estimatedPomodoros, completedPomodoros)
        dismiss()
    }
}
