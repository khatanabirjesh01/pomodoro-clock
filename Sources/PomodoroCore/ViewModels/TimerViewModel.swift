import Foundation
import Combine
import SwiftUI

public enum TimerState: String, Sendable {
    case idle = "Idle"
    case running = "Running"
    case paused = "Paused"
    case completed = "Completed"
    case transitioning = "Transitioning"
}

@MainActor
public final class TimerViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published public var currentPhase: SessionType = .focus
    @Published public var timerState: TimerState = .idle
    @Published public var remainingSeconds: Int = 25 * 60
    @Published public var totalSeconds: Int = 25 * 60
    @Published public var completedFocusInCycle: Int = 0
    @Published public var autoTransitionRemainingSeconds: Int = 0
    @Published public var settings: AppSettings {
        didSet {
            storage.saveSettings(settings)
            if timerState == .idle {
                syncDurationWithSettings()
            }
        }
    }
    
    // Dependencies
    public var taskViewModel: TaskViewModel?
    public var progressViewModel: ProgressViewModel?
    
    private let storage: StorageService
    private let soundManager: SoundManager
    private let notificationManager: NotificationManager
    
    private var timerCancellable: AnyCancellable?
    private var transitionTimerCancellable: AnyCancellable?
    
    // MARK: - Initializer
    
    public init(
        storage: StorageService = .shared,
        soundManager: SoundManager = .shared,
        notificationManager: NotificationManager = .shared
    ) {
        self.storage = storage
        self.soundManager = soundManager
        self.notificationManager = notificationManager
        
        let loadedSettings = storage.loadSettings()
        self.settings = loadedSettings
        self.remainingSeconds = loadedSettings.focusMinutes * 60
        self.totalSeconds = loadedSettings.focusMinutes * 60
        
        setupNotificationHandling()
    }
    
    private func setupNotificationHandling() {
        notificationManager.requestAuthorization()
        notificationManager.onActionSelected = { [weak self] action in
            guard let self = self else { return }
            Task { @MainActor in
                if action == "START_NEXT" {
                    self.start()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    public var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(totalSeconds))
    }
    
    public var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    public var isRunning: Bool {
        timerState == .running
    }
    
    public var isPaused: Bool {
        timerState == .paused
    }
    
    // MARK: - Timer Controls
    
    public func start() {
        cancelTransitionTimer()
        
        if timerState == .completed || remainingSeconds <= 0 {
            syncDurationWithSettings()
        }
        
        timerState = .running
        startTicking()
    }
    
    public func pause() {
        guard timerState == .running else { return }
        timerState = .paused
        stopTicking()
    }
    
    public func resume() {
        guard timerState == .paused else { return }
        timerState = .running
        startTicking()
    }
    
    public func togglePlayPause() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }
    
    public func reset() {
        stopTicking()
        cancelTransitionTimer()
        timerState = .idle
        syncDurationWithSettings()
    }
    
    public func skip() {
        stopTicking()
        cancelTransitionTimer()
        advanceToNextPhase()
        timerState = .idle
        syncDurationWithSettings()
    }
    
    public func switchPhase(to phase: SessionType) {
        guard currentPhase != phase else { return }
        stopTicking()
        cancelTransitionTimer()
        currentPhase = phase
        timerState = .idle
        syncDurationWithSettings()
    }
    
    public func setTimerMode(_ mode: TimerMode) {
        settings.timerMode = mode
    }
    
    // MARK: - Internal Timer Loop
    
    private func startTicking() {
        stopTicking()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    private func stopTicking() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            handleSessionCompletion()
            return
        }
        remainingSeconds -= 1
        
        if remainingSeconds == 0 {
            handleSessionCompletion()
        }
    }
    
    // MARK: - Session Completion Logic
    
    private func handleSessionCompletion() {
        stopTicking()
        
        let completedPhase = currentPhase
        let durationMinutes = totalSeconds / 60
        let activeTask = taskViewModel?.activeTask
        
        // 1. Log completed session to Daily Progress
        progressViewModel?.recordSession(
            type: completedPhase,
            durationMinutes: max(1, durationMinutes),
            taskName: activeTask?.title,
            taskId: activeTask?.id,
            mode: settings.timerMode,
            isManual: false
        )
        
        // 2. Increment active task completed count if focus
        if completedPhase == .focus {
            taskViewModel?.incrementCompletedPomodoro(for: activeTask?.id)
            completedFocusInCycle += 1
        }
        
        // 3. Play audio
        playAlertSound(for: completedPhase)
        
        // 4. Send native macOS notification banner
        sendCompletionNotification(for: completedPhase, task: activeTask)
        
        // 5. Advance phase logic
        advanceToNextPhase()
        
        // 6. Handle Timer Mode (Normal vs Progressive)
        if settings.timerMode == .normal {
            timerState = .completed
            syncDurationWithSettings()
        } else {
            // Progressive Mode: Automatically transitions into the next phase
            if settings.progressiveDelaySeconds > 0 {
                timerState = .transitioning
                autoTransitionRemainingSeconds = settings.progressiveDelaySeconds
                syncDurationWithSettings()
                startTransitionTimer()
            } else {
                timerState = .running
                syncDurationWithSettings()
                startTicking()
            }
        }
    }
    
    private func advanceToNextPhase() {
        switch currentPhase {
        case .focus:
            if completedFocusInCycle >= settings.longBreakInterval {
                currentPhase = .longBreak
                completedFocusInCycle = 0
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .focus
        }
    }
    
    private func startTransitionTimer() {
        cancelTransitionTimer()
        transitionTimerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.autoTransitionRemainingSeconds > 1 {
                    self.autoTransitionRemainingSeconds -= 1
                } else {
                    self.cancelTransitionTimer()
                    self.start()
                }
            }
    }
    
    private func cancelTransitionTimer() {
        transitionTimerCancellable?.cancel()
        transitionTimerCancellable = nil
    }
    
    // MARK: - Alerts & Audio
    
    private func playAlertSound(for phase: SessionType) {
        guard settings.soundEnabled else { return }
        let soundName = phase == .focus ? settings.focusEndSound : settings.breakEndSound
        soundManager.playSound(named: soundName)
    }
    
    private func sendCompletionNotification(for phase: SessionType, task: TaskItem?) {
        guard settings.notificationsEnabled else { return }
        
        let title: String
        let body: String
        
        switch phase {
        case .focus:
            title = "🍅 Focus Session Complete!"
            if let task = task {
                body = "Great job working on \"\(task.title)\"! Time to take a restful break."
            } else {
                body = "Fantastic focus! Time to take a well-deserved break."
            }
        case .shortBreak, .longBreak:
            title = "☕ Break Over!"
            body = "Ready to dive back into your next focus session? Let's go!"
        }
        
        notificationManager.sendNotification(
            title: title,
            subtitle: settings.timerMode == .progressive ? "Progressive mode: Next phase starting automatically" : nil,
            body: body
        )
    }
    
    public func syncDurationWithSettings() {
        let minutes: Int
        switch currentPhase {
        case .focus:
            minutes = settings.focusMinutes
        case .shortBreak:
            minutes = settings.shortBreakMinutes
        case .longBreak:
            minutes = settings.longBreakMinutes
        }
        totalSeconds = minutes * 60
        remainingSeconds = totalSeconds
    }
}
