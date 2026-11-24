import Foundation
import Combine

public enum TaskFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
    
    public var id: String { rawValue }
}

@MainActor
public final class TaskViewModel: ObservableObject {
    @Published public var tasks: [TaskItem] = []
    @Published public var activeTaskId: UUID? = nil
    @Published public var filter: TaskFilter = .all
    
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
        self.tasks = storage.loadTasks()
        if self.tasks.isEmpty {
            // Seed a helpful welcoming task
            let sample = TaskItem(
                title: "Welcome to Pomodoro! Plan your first session",
                notes: "Click the target icon to set this as your active focus task.",
                estimatedPomodoros: 2
            )
            self.tasks = [sample]
            self.activeTaskId = sample.id
            storage.saveTasks(self.tasks)
        } else {
            // Pick the first uncompleted task as active default if none
            self.activeTaskId = tasks.first(where: { !$0.isCompleted })?.id
        }
    }
    
    public var filteredTasks: [TaskItem] {
        switch filter {
        case .all:
            return tasks
        case .active:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }
    
    public var activeTask: TaskItem? {
        guard let id = activeTaskId else { return nil }
        return tasks.first(where: { $0.id == id })
    }
    
    public func setActiveTask(_ task: TaskItem?) {
        activeTaskId = task?.id
    }
    
    public func addTask(title: String, notes: String = "", estimatedPomodoros: Int = 1) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newTask = TaskItem(
            title: trimmed,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            estimatedPomodoros: estimatedPomodoros
        )
        tasks.insert(newTask, at: 0)
        if activeTaskId == nil {
            activeTaskId = newTask.id
        }
        storage.saveTasks(tasks)
    }
    
    public func updateTask(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            storage.saveTasks(tasks)
        }
    }
    
    public func toggleCompletion(_ task: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updated = tasks[index]
            updated.isCompleted.toggle()
            updated.completedAt = updated.isCompleted ? Date() : nil
            tasks[index] = updated
            
            // If active task completed, clear active or pick next active
            if activeTaskId == updated.id && updated.isCompleted {
                activeTaskId = tasks.first(where: { !$0.isCompleted && $0.id != updated.id })?.id
            }
            
            storage.saveTasks(tasks)
        }
    }
    
    public func deleteTask(_ task: TaskItem) {
        tasks.removeAll(where: { $0.id == task.id })
        if activeTaskId == task.id {
            activeTaskId = tasks.first(where: { !$0.isCompleted })?.id
        }
        storage.saveTasks(tasks)
    }
    
    public func incrementCompletedPomodoro(for taskId: UUID?) {
        guard let taskId = taskId,
              let index = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        var updated = tasks[index]
        updated.completedPomodoros += 1
        tasks[index] = updated
        storage.saveTasks(tasks)
    }
}
