import SwiftUI

public enum NavigationTab: String, CaseIterable, Identifiable {
    case timer = "Timer"
    case tasks = "Tasks"
    case progress = "Daily Progress"
    case calendar = "Streak Calendar"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .timer:
            return "timer"
        case .tasks:
            return "checklist"
        case .progress:
            return "chart.bar.xaxis"
        case .calendar:
            return "calendar"
        case .settings:
            return "gearshape"
        }
    }
}

public struct SidebarView: View {
    @Binding var selectedTab: NavigationTab?
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var streakViewModel: StreakViewModel
    
    public init(
        selectedTab: Binding<NavigationTab?>,
        timerViewModel: TimerViewModel,
        progressViewModel: ProgressViewModel,
        streakViewModel: StreakViewModel
    ) {
        self._selectedTab = selectedTab
        self.timerViewModel = timerViewModel
        self.progressViewModel = progressViewModel
        self.streakViewModel = streakViewModel
    }
    
    public var body: some View {
        List(selection: $selectedTab) {
            Section("Pomodoro") {
                NavigationLink(value: NavigationTab.timer) {
                    Label(NavigationTab.timer.rawValue, systemImage: NavigationTab.timer.iconName)
                }
                
                NavigationLink(value: NavigationTab.tasks) {
                    Label(NavigationTab.tasks.rawValue, systemImage: NavigationTab.tasks.iconName)
                }
            }
            
            Section("Productivity") {
                NavigationLink(value: NavigationTab.progress) {
                    HStack {
                        Label(NavigationTab.progress.rawValue, systemImage: NavigationTab.progress.iconName)
                        Spacer()
                        if progressViewModel.todayFocusCount > 0 {
                            Text("\(progressViewModel.todayFocusCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.red.opacity(0.15)))
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                NavigationLink(value: NavigationTab.calendar) {
                    HStack {
                        Label(NavigationTab.calendar.rawValue, systemImage: NavigationTab.calendar.iconName)
                        Spacer()
                        let streak = streakViewModel.calculateCurrentStreak(sessions: progressViewModel.sessions)
                        if streak > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("\(streak)")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.orange.opacity(0.18)))
                            .foregroundStyle(.orange)
                        }
                    }
                }
            }
            
            Section("Preferences") {
                NavigationLink(value: NavigationTab.settings) {
                    Label(NavigationTab.settings.rawValue, systemImage: NavigationTab.settings.iconName)
                }
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}
