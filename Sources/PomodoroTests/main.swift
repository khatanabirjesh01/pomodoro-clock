import Foundation
import PomodoroCore

// MARK: - Test Assertion Suite

@MainActor
final class TestRunner {
    var totalTestsRun = 0
    var totalTestsPassed = 0
    var totalTestsFailed = 0
    
    func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
        totalTestsRun += 1
        if actual == expected {
            totalTestsPassed += 1
            print("  ✓ PASS: \(message.isEmpty ? "\(actual) == \(expected)" : message)")
        } else {
            totalTestsFailed += 1
            print("  ✗ FAIL: \(message) - Expected: '\(expected)', got: '\(actual)' at \(file):\(line)")
        }
    }

    func assertTrue(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
        totalTestsRun += 1
        if condition {
            totalTestsPassed += 1
            print("  ✓ PASS: \(message)")
        } else {
            totalTestsFailed += 1
            print("  ✗ FAIL: \(message) (condition was false) at \(file):\(line)")
        }
    }

    func assertFalse(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
        assertTrue(!condition, message, file: file, line: line)
    }

    func runSuite(_ name: String, block: () throws -> Void) {
        print("\n═══════════════════════════════════════════════════")
        print("▶ Running Test Suite: \(name)")
        print("═══════════════════════════════════════════════════")
        do {
            try block()
        } catch {
            print("Suite error: \(error)")
            totalTestsFailed += 1
        }
    }
}

@main
struct PomodoroTestsMain {
    @MainActor
    static func main() {
        let runner = TestRunner()
    
    // Suite 1
    runner.runSuite("Feature 1: Modifiable Timers & Phase Switching") {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let storage = StorageService(customDirectory: tempDir)
        let vm = TimerViewModel(storage: storage)
        
        runner.assertEqual(vm.currentPhase, .focus, "Initial phase is Focus")
        runner.assertEqual(vm.remainingSeconds, 25 * 60, "Default focus duration is 25 minutes (1500s)")
        runner.assertEqual(vm.formattedTime, "25:00", "Default formatted time is 25:00")
        
        // Switch to Short Break (default 5 min)
        vm.switchPhase(to: .shortBreak)
        runner.assertEqual(vm.currentPhase, .shortBreak, "Switched to Short Break")
        runner.assertEqual(vm.remainingSeconds, 5 * 60, "Default short break is 5 minutes (300s)")
        runner.assertEqual(vm.formattedTime, "05:00", "Formatted time is 05:00")
        
        // Switch to Long Break (default 15 min)
        vm.switchPhase(to: .longBreak)
        runner.assertEqual(vm.currentPhase, .longBreak, "Switched to Long Break")
        runner.assertEqual(vm.remainingSeconds, 15 * 60, "Default long break is 15 minutes (900s)")
        runner.assertEqual(vm.formattedTime, "15:00", "Formatted time is 15:00")
        
        // Customize Durations
        vm.settings.focusMinutes = 50
        vm.settings.shortBreakMinutes = 10
        vm.settings.longBreakMinutes = 20
        vm.switchPhase(to: .focus)
        runner.assertEqual(vm.remainingSeconds, 50 * 60, "Custom focus duration updated to 50 minutes")
        runner.assertEqual(vm.formattedTime, "50:00", "Formatted time updated to 50:00")
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    // Suite 2
    runner.runSuite("Feature 2: Timer Modes (Normal vs Progressive)") {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let storage = StorageService(customDirectory: tempDir)
        let vm = TimerViewModel(storage: storage)
        
        runner.assertEqual(vm.settings.timerMode, .normal, "Default timer mode is Normal")
        
        // Switch to progressive mode
        vm.setTimerMode(.progressive)
        runner.assertEqual(vm.settings.timerMode, .progressive, "Timer mode updated to Progressive")
        runner.assertTrue(vm.settings.timerMode.description.contains("Automatically"), "Progressive mode description verified")
        
        // Controls test
        vm.start()
        runner.assertEqual(vm.timerState, .running, "Timer starts running")
        runner.assertTrue(vm.isRunning, "isRunning is true")
        
        vm.pause()
        runner.assertEqual(vm.timerState, .paused, "Timer pauses")
        runner.assertTrue(vm.isPaused, "isPaused is true")
        
        vm.resume()
        runner.assertEqual(vm.timerState, .running, "Timer resumes")
        
        vm.reset()
        runner.assertEqual(vm.timerState, .idle, "Timer resets to idle")
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    // Suite 3
    runner.runSuite("Feature 3: Alerts & Audio Configuration") {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let storage = StorageService(customDirectory: tempDir)
        let vm = TimerViewModel(storage: storage)
        
        runner.assertTrue(vm.settings.soundEnabled, "Sound alert enabled by default")
        runner.assertTrue(vm.settings.notificationsEnabled, "macOS notifications enabled by default")
        runner.assertEqual(vm.settings.focusEndSound, "Glass", "Default focus sound is Glass")
        runner.assertEqual(vm.settings.breakEndSound, "Hero", "Default break sound is Hero")
        
        runner.assertTrue(SoundManager.availableSounds.contains("Ping"), "Available sounds contain Ping")
        runner.assertTrue(SoundManager.availableSounds.contains("Hero"), "Available sounds contain Hero")
        runner.assertTrue(SoundManager.availableSounds.contains("Glass"), "Available sounds contain Glass")
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    // Suite 4
    runner.runSuite("Feature 4: Task Manager & Pomodoro Linkage") {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let storage = StorageService(customDirectory: tempDir)
        let taskVM = TaskViewModel(storage: storage)
        let timerVM = TimerViewModel(storage: storage)
        timerVM.taskViewModel = taskVM
        
        // Add task
        taskVM.addTask(title: "Implement Core Feature", notes: "Writing tests", estimatedPomodoros: 4)
        guard let task = taskVM.tasks.first(where: { $0.title == "Implement Core Feature" }) else {
            fatalError("Task not added")
        }
        
        runner.assertEqual(task.estimatedPomodoros, 4, "Estimated pomodoros is 4")
        runner.assertEqual(task.completedPomodoros, 0, "Completed pomodoros starts at 0")
        runner.assertFalse(task.isCompleted, "Task initially not completed")
        
        // Set active task
        taskVM.setActiveTask(task)
        runner.assertEqual(taskVM.activeTaskId, task.id, "Active task id set")
        runner.assertEqual(taskVM.activeTask?.title, "Implement Core Feature", "Active task title matches")
        
        // Increment pomodoro on completion
        taskVM.incrementCompletedPomodoro(for: task.id)
        let updated = taskVM.tasks.first(where: { $0.id == task.id })!
        runner.assertEqual(updated.completedPomodoros, 1, "Completed pomodoros incremented to 1")
        
        // Toggle completion
        taskVM.toggleCompletion(updated)
        let completedTask = taskVM.tasks.first(where: { $0.id == task.id })!
        runner.assertTrue(completedTask.isCompleted, "Task marked as completed")
        
        // Filtering
        taskVM.filter = .completed
        runner.assertTrue(taskVM.filteredTasks.contains(where: { $0.id == task.id }), "Completed filter includes task")
        
        taskVM.filter = .active
        runner.assertFalse(taskVM.filteredTasks.contains(where: { $0.id == task.id }), "Active filter excludes completed task")
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    // Suite 5
    runner.runSuite("Feature 5: Daily Progress Logger & Manual Entry") {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let storage = StorageService(customDirectory: tempDir)
        let progressVM = ProgressViewModel(storage: storage)
        
        runner.assertEqual(progressVM.todayFocusCount, 0, "Initially 0 focus sessions today")
        
        // Automatic session recording
        progressVM.recordSession(
            type: .focus,
            durationMinutes: 25,
            taskName: "SwiftUI Design",
            taskId: UUID(),
            mode: .normal,
            isManual: false
        )
        
        runner.assertEqual(progressVM.todayFocusCount, 1, "Today's focus count is 1")
        runner.assertEqual(progressVM.todayFocusMinutes, 25, "Today's focus minutes is 25")
        
        // Manual entry via '+' button
        progressVM.addManualSession(
            type: .focus,
            durationMinutes: 30,
            date: Date(),
            taskName: "Offline Brainstorming",
            notes: "Whiteboard session"
        )
        
        runner.assertEqual(progressVM.todayFocusCount, 2, "Today's focus count increased to 2 after manual entry")
        runner.assertEqual(progressVM.todayFocusMinutes, 55, "Today's focus minutes increased to 55")
        
        // Quick session count adjustment
        progressVM.adjustTodayCount(by: 2, defaultDuration: 25)
        runner.assertEqual(progressVM.todayFocusCount, 4, "Tally adjustment (+2) increased today's focus count to 4")
        
        progressVM.adjustTodayCount(by: -1, defaultDuration: 25)
        runner.assertEqual(progressVM.todayFocusCount, 3, "Tally adjustment (-1) decreased today's focus count to 3")
        
        // Goal progress
        let goalProgress = progressVM.goalProgress(goal: 6)
        runner.assertEqual(goalProgress, 0.5, "Goal progress 3/6 is 0.5 (50%)")
        
        try? FileManager.default.removeItem(at: tempDir)
    }

    // Suite 6
    runner.runSuite("Feature 6: Streak Calendar & Consecutive Days Calculation") {
        let streakVM = StreakViewModel()
        let calendar = Calendar.current
        let today = Date()
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today),
              let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today),
              let tenDaysAgo = calendar.date(byAdding: .day, value: -10, to: today),
              let elevenDaysAgo = calendar.date(byAdding: .day, value: -11, to: today),
              let twelveDaysAgo = calendar.date(byAdding: .day, value: -12, to: today),
              let thirteenDaysAgo = calendar.date(byAdding: .day, value: -13, to: today) else {
            fatalError("Calendar calculations failed")
        }
        
        // Test Streak of 4 days up to today
        let sessionsCurrentStreak = [
            PomodoroSession(timestamp: today, sessionType: .focus, durationMinutes: 25),
            PomodoroSession(timestamp: yesterday, sessionType: .focus, durationMinutes: 25),
            PomodoroSession(timestamp: twoDaysAgo, sessionType: .focus, durationMinutes: 25),
            PomodoroSession(timestamp: threeDaysAgo, sessionType: .focus, durationMinutes: 25)
        ]
        
        let currentStreak = streakVM.calculateCurrentStreak(sessions: sessionsCurrentStreak)
        runner.assertEqual(currentStreak, 4, "Current streak is 4 consecutive days including today")
        
        // Test Streak still alive from yesterday when today has no sessions yet
        let sessionsYesterdayOnly = [
            PomodoroSession(timestamp: yesterday, sessionType: .focus, durationMinutes: 25),
            PomodoroSession(timestamp: twoDaysAgo, sessionType: .focus, durationMinutes: 25)
        ]
        let aliveStreak = streakVM.calculateCurrentStreak(sessions: sessionsYesterdayOnly)
        runner.assertEqual(aliveStreak, 2, "Streak of 2 days is kept alive if yesterday had focus sessions")
        
        // Test Longest Streak historical
        let allSessions = [
            // Old 4-day streak
            PomodoroSession(timestamp: thirteenDaysAgo, sessionType: .focus),
            PomodoroSession(timestamp: twelveDaysAgo, sessionType: .focus),
            PomodoroSession(timestamp: elevenDaysAgo, sessionType: .focus),
            PomodoroSession(timestamp: tenDaysAgo, sessionType: .focus),
            // Recent 2-day streak
            PomodoroSession(timestamp: yesterday, sessionType: .focus),
            PomodoroSession(timestamp: today, sessionType: .focus)
        ]
        let longest = streakVM.calculateLongestStreak(sessions: allSessions)
        runner.assertEqual(longest, 4, "Best streak of 4 days identified")
        
        // Calendar grid generation
        let days = streakVM.generateDaysForDisplayedMonth(sessions: allSessions)
        runner.assertTrue(days.count >= 28, "Calendar generates full month grid of days")
        runner.assertTrue(days.contains(where: { $0.isToday }), "Calendar grid contains today's cell")
    }

    // Summary
    print("\n═══════════════════════════════════════════════════")
    print("TEST EXECUTION SUMMARY:")
    print("  Total Tests Run:    \(runner.totalTestsRun)")
    print("  Total Passed:       \(runner.totalTestsPassed)")
    print("  Total Failed:       \(runner.totalTestsFailed)")
    print("═══════════════════════════════════════════════════\n")

        if runner.totalTestsFailed == 0 {
            print("🎉 ALL TESTS PASSED SUCCESSFULLY!")
            exit(0)
        } else {
            print("❌ SOME TESTS FAILED")
            exit(1)
        }
    }
}
