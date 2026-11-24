import SwiftUI

public struct TimerView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @ObservedObject var taskViewModel: TaskViewModel
    
    @ViewState private var showingTaskPicker = false
    
    public init(timerViewModel: TimerViewModel, taskViewModel: TaskViewModel) {
        self.timerViewModel = timerViewModel
        self.taskViewModel = taskViewModel
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            // Top Bar: Phase Switcher & Mode Badge
            HStack {
                // Phase picker segmented control
                Picker("Phase", selection: Binding(
                    get: { timerViewModel.currentPhase },
                    set: { timerViewModel.switchPhase(to: $0) }
                )) {
                    Text("Focus").tag(SessionType.focus)
                    Text("Short Break").tag(SessionType.shortBreak)
                    Text("Long Break").tag(SessionType.longBreak)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)
                
                Spacer()
                
                // Timer Mode Toggle Pill
                Button {
                    let newMode: TimerMode = timerViewModel.settings.timerMode == .normal ? .progressive : .normal
                    timerViewModel.setTimerMode(newMode)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: timerViewModel.settings.timerMode.iconName)
                        Text(timerViewModel.settings.timerMode.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(timerViewModel.settings.timerMode == .progressive ? Color.purple.opacity(0.18) : Color.secondary.opacity(0.15))
                    )
                    .foregroundStyle(timerViewModel.settings.timerMode == .progressive ? Color.purple : Color.secondary)
                }
                .buttonStyle(.plain)
                .help("Timer Mode: \(timerViewModel.settings.timerMode.description) Click to switch.")
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            // Active Task Badge Card
            HStack(spacing: 12) {
                if let active = taskViewModel.activeTask {
                    Image(systemName: "target")
                        .foregroundStyle(.red)
                        .font(.title3)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(active.title)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                        Text("Goal: \(active.completedPomodoros)/\(active.estimatedPomodoros) pomodoros")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "plus.circle.dashed")
                        .foregroundStyle(.secondary)
                    Text("No task linked to this session")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button(taskViewModel.activeTask == nil ? "Link Task" : "Change") {
                    showingTaskPicker = true
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Circular Progress Ring
            CircularProgressView(
                progress: timerViewModel.progress,
                timeString: timerViewModel.formattedTime,
                phase: timerViewModel.currentPhase,
                isRunning: timerViewModel.isRunning,
                transitionCountdown: timerViewModel.timerState == .transitioning ? timerViewModel.autoTransitionRemainingSeconds : nil
            )
            
            // Cycle Progress Indicator (Pomodoro interval)
            HStack(spacing: 8) {
                ForEach(0..<timerViewModel.settings.longBreakInterval, id: \.self) { index in
                    Circle()
                        .fill(index < timerViewModel.completedFocusInCycle ? Color.red : Color.secondary.opacity(0.25))
                        .frame(width: 9, height: 9)
                }
                Text("\(timerViewModel.completedFocusInCycle) / \(timerViewModel.settings.longBreakInterval) to Long Break")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 24) {
                // Reset Button
                Button {
                    timerViewModel.reset()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                .help("Reset Session (⌘R)")
                .keyboardShortcut("r", modifiers: .command)
                
                // Play / Pause Main Button
                Button {
                    timerViewModel.togglePlayPause()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title2)
                        Text(timerViewModel.isRunning ? "Pause" : (timerViewModel.isPaused ? "Resume" : "Start"))
                            .font(.headline)
                    }
                    .frame(minWidth: 140, minHeight: 48)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accent(for: timerViewModel.currentPhase))
                .clipShape(Capsule())
                .keyboardShortcut(.space, modifiers: [])
                .help("Start / Pause (Space)")
                
                // Skip Button
                Button {
                    timerViewModel.skip()
                } label: {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .clipShape(Circle())
                .help("Skip to next phase (⌘S)")
                .keyboardShortcut("s", modifiers: .command)
            }
            .padding(.bottom, 24)
        }
        .frame(minWidth: 500, minHeight: 520)
        .sheet(isPresented: $showingTaskPicker) {
            ActiveTaskPickerSheet(taskViewModel: taskViewModel)
        }
    }
}
