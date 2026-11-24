import SwiftUI
import AppKit

public struct SettingsView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @ViewState private var previewFeedbackText: String? = nil
    
    public init(timerViewModel: TimerViewModel) {
        self.timerViewModel = timerViewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Configure timer durations, behavior, audio cues, and notifications.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding([.top, .horizontal])
                
                // Section 1: Timer Durations & Presets
                GroupBox(label: Label("Timer Durations", systemImage: "clock")) {
                    VStack(alignment: .leading, spacing: 14) {
                        // Quick Presets
                        HStack {
                            Text("Presets:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Button("Classic (25/5/15)") {
                                applyPreset(focus: 25, short: 5, long: 15)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button("Deep Focus (50/10/20)") {
                                applyPreset(focus: 50, short: 10, long: 20)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button("Quick Sprint (15/3/10)") {
                                applyPreset(focus: 15, short: 3, long: 10)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.top, 4)
                        
                        Divider()
                        
                        // Focus Duration
                        HStack {
                            Label("Focus Duration", systemImage: "flame.fill")
                                .foregroundStyle(.red)
                            Spacer()
                            Stepper("\(timerViewModel.settings.focusMinutes) min", value: $timerViewModel.settings.focusMinutes, in: 1...120)
                        }
                        
                        // Short Break
                        HStack {
                            Label("Short Break Duration", systemImage: "cup.and.saucer.fill")
                                .foregroundStyle(.teal)
                            Spacer()
                            Stepper("\(timerViewModel.settings.shortBreakMinutes) min", value: $timerViewModel.settings.shortBreakMinutes, in: 1...60)
                        }
                        
                        // Long Break
                        HStack {
                            Label("Long Break Duration", systemImage: "leaf.fill")
                                .foregroundStyle(.blue)
                            Spacer()
                            Stepper("\(timerViewModel.settings.longBreakMinutes) min", value: $timerViewModel.settings.longBreakMinutes, in: 1...90)
                        }
                        
                        // Long Break Interval
                        HStack {
                            Label("Long Break Interval", systemImage: "repeat")
                                .foregroundStyle(.purple)
                            Spacer()
                            Stepper("Every \(timerViewModel.settings.longBreakInterval) sessions", value: $timerViewModel.settings.longBreakInterval, in: 2...12)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                // Section 2: Timer Modes
                GroupBox(label: Label("Timer Mode Behavior", systemImage: "arrow.triangle.2.circlepath")) {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Timer Mode", selection: $timerViewModel.settings.timerMode) {
                            Text("Normal Mode").tag(TimerMode.normal)
                            Text("Progressive Mode").tag(TimerMode.progressive)
                        }
                        .pickerStyle(.radioGroup)
                        
                        Text(timerViewModel.settings.timerMode.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 20)
                        
                        if timerViewModel.settings.timerMode == .progressive {
                            Divider()
                            HStack {
                                Text("Auto-advance transition delay:")
                                    .font(.caption)
                                Spacer()
                                Stepper("\(timerViewModel.settings.progressiveDelaySeconds) seconds", value: $timerViewModel.settings.progressiveDelaySeconds, in: 0...15)
                            }
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                // Section 3: Alerts & Audio
                GroupBox(label: Label("Alerts & Sound Effects", systemImage: "speaker.wave.2")) {
                    VStack(alignment: .leading, spacing: 14) {
                        Toggle("Play Built-in System Sound on Completion", isOn: $timerViewModel.settings.soundEnabled)
                        
                        if timerViewModel.settings.soundEnabled {
                            HStack {
                                Text("Focus Complete Sound:")
                                    .frame(width: 170, alignment: .leading)
                                Picker("", selection: $timerViewModel.settings.focusEndSound) {
                                    ForEach(SoundManager.availableSounds, id: \.self) { sound in
                                        Text(sound).tag(sound)
                                    }
                                }
                                .frame(width: 130)
                                
                                Button("Test") {
                                    SoundManager.shared.playSound(named: timerViewModel.settings.focusEndSound)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            
                            HStack {
                                Text("Break Complete Sound:")
                                    .frame(width: 170, alignment: .leading)
                                Picker("", selection: $timerViewModel.settings.breakEndSound) {
                                    ForEach(SoundManager.availableSounds, id: \.self) { sound in
                                        Text(sound).tag(sound)
                                    }
                                }
                                .frame(width: 130)
                                
                                Button("Test") {
                                    SoundManager.shared.playSound(named: timerViewModel.settings.breakEndSound)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                        }
                        
                        Divider()
                        
                        Toggle("Show macOS Notification Banner", isOn: $timerViewModel.settings.notificationsEnabled)
                        
                        if timerViewModel.settings.notificationsEnabled {
                            Button("Send Test Notification") {
                                NotificationManager.shared.sendNotification(
                                    title: "🍅 Pomodoro Notification Test",
                                    subtitle: "Everything is configured perfectly!",
                                    body: "Native notifications are fully enabled and ready to keep you on schedule."
                                )
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                // Section 4: Daily Goals
                GroupBox(label: Label("Daily Targets", systemImage: "target")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Focus Goal:")
                            Spacer()
                            Stepper("\(timerViewModel.settings.dailyGoalCount) sessions", value: $timerViewModel.settings.dailyGoalCount, in: 1...20)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)
                
                // Section 5: Data Storage
                GroupBox(label: Label("Local Data & Storage", systemImage: "internaldrive")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Data is stored locally on your Mac in JSON format for privacy and portability:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(StorageService.shared.storageDirectoryPath)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                        
                        HStack {
                            Button("Reveal in Finder") {
                                let url = URL(fileURLWithPath: StorageService.shared.storageDirectoryPath)
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.top, 4)
                    }
                    .padding(8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
    }
    
    private func applyPreset(focus: Int, short: Int, long: Int) {
        timerViewModel.settings.focusMinutes = focus
        timerViewModel.settings.shortBreakMinutes = short
        timerViewModel.settings.longBreakMinutes = long
        timerViewModel.syncDurationWithSettings()
    }
}
