import SwiftUI

public struct ManualEntrySheet: View {
    let tasks: [TaskItem]
    let onSave: (SessionType, Int, Date, String?, String?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @ViewState private var sessionType: SessionType = .focus
    @ViewState private var durationMinutes: Int = 25
    @ViewState private var date: Date = Date()
    @ViewState private var selectedTaskName: String = ""
    @ViewState private var customTaskName: String = ""
    @ViewState private var notes: String = ""
    
    public init(tasks: [TaskItem] = [], onSave: @escaping (SessionType, Int, Date, String?, String?) -> Void) {
        self.tasks = tasks
        self.onSave = onSave
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Log Past Session")
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
            }
            .padding([.top, .horizontal])
            
            Form {
                Picker("Session Type", selection: $sessionType) {
                    ForEach(SessionType.allCases) { type in
                        Label(type.rawValue, systemImage: type.iconName).tag(type)
                    }
                }
                
                Stepper("Duration: \(durationMinutes) minutes", value: $durationMinutes, in: 1...180, step: 5)
                
                DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                
                if !tasks.isEmpty {
                    Picker("Link to Task", selection: $selectedTaskName) {
                        Text("None / General Focus").tag("")
                        ForEach(tasks) { task in
                            Text(task.title).tag(task.title)
                        }
                    }
                }
                
                if selectedTaskName.isEmpty {
                    TextField("Custom Task or Label", text: $customTaskName)
                        .textFieldStyle(.roundedBorder)
                }
                
                TextField("Notes (optional)", text: $notes)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(width: 420, height: 320)
    }
    
    private func save() {
        let taskName = selectedTaskName.isEmpty ? (customTaskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : customTaskName) : selectedTaskName
        let noteString = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        onSave(sessionType, durationMinutes, date, taskName, noteString)
        dismiss()
    }
}
