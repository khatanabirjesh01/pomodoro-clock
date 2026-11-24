import SwiftUI

public struct TaskListView: View {
    @ObservedObject var taskViewModel: TaskViewModel
    
    @ViewState private var quickTitle = ""
    @ViewState private var taskToEdit: TaskItem? = nil
    @ViewState private var showingAddSheet = false
    
    public init(taskViewModel: TaskViewModel) {
        self.taskViewModel = taskViewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tasks")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(taskViewModel.tasks.filter { !$0.isCompleted }.count) active • \(taskViewModel.tasks.filter { $0.isCompleted }.count) completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Picker("Filter", selection: $taskViewModel.filter) {
                    ForEach(TaskFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
                
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            // Quick Add Input Row
            HStack(spacing: 8) {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.secondary)
                
                TextField("Add a new task and press Return...", text: $quickTitle)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        submitQuickTask()
                    }
                
                if !quickTitle.isEmpty {
                    Button("Add") {
                        submitQuickTask()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            Divider()
            
            // Task List
            let listItems = taskViewModel.filteredTasks
            if listItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "checklist")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.6))
                    Text(taskViewModel.filter == .completed ? "No completed tasks yet" : "No tasks in this view")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Add your next goal above to link it with your Pomodoro timer.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(listItems) { task in
                        TaskRowView(
                            task: task,
                            isActive: taskViewModel.activeTaskId == task.id,
                            onToggleComplete: {
                                taskViewModel.toggleCompletion(task)
                            },
                            onSetActive: {
                                if taskViewModel.activeTaskId == task.id {
                                    taskViewModel.setActiveTask(nil)
                                } else {
                                    taskViewModel.setActiveTask(task)
                                }
                            },
                            onEdit: {
                                taskToEdit = task
                            },
                            onDelete: {
                                taskViewModel.deleteTask(task)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    }
                }
                .listStyle(.inset)
            }
        }
        .sheet(item: $taskToEdit) { task in
            TaskEditorSheet(taskToEdit: task) { title, notes, est, comp in
                var updated = task
                updated.title = title
                updated.notes = notes
                updated.estimatedPomodoros = est
                updated.completedPomodoros = comp
                taskViewModel.updateTask(updated)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            TaskEditorSheet { title, notes, est, comp in
                taskViewModel.addTask(title: title, notes: notes, estimatedPomodoros: est)
            }
        }
    }
    
    private func submitQuickTask() {
        let trimmed = quickTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        taskViewModel.addTask(title: trimmed)
        quickTitle = ""
    }
}
