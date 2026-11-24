import SwiftUI

public struct MainView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var streakViewModel = StreakViewModel()
    
    @ViewState private var selectedTab: NavigationTab? = .timer
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedTab: $selectedTab,
                timerViewModel: timerViewModel,
                progressViewModel: progressViewModel,
                streakViewModel: streakViewModel
            )
        } detail: {
            Group {
                switch selectedTab ?? .timer {
                case .timer:
                    TimerView(
                        timerViewModel: timerViewModel,
                        taskViewModel: taskViewModel
                    )
                case .tasks:
                    TaskListView(taskViewModel: taskViewModel)
                case .progress:
                    DailyProgressView(
                        progressViewModel: progressViewModel,
                        taskViewModel: taskViewModel,
                        dailyGoal: timerViewModel.settings.dailyGoalCount
                    )
                case .calendar:
                    StreakCalendarView(
                        streakViewModel: streakViewModel,
                        progressViewModel: progressViewModel
                    )
                case .settings:
                    SettingsView(timerViewModel: timerViewModel)
                }
            }
            .frame(minWidth: 520, minHeight: 560)
        }
        .onAppear {
            // Wire dependencies
            timerViewModel.taskViewModel = taskViewModel
            timerViewModel.progressViewModel = progressViewModel
        }
    }
}
