# 🍅 Pomodoro — Native macOS Desktop Application

A clean, modern, native macOS Pomodoro desktop application crafted with **Swift** and **SwiftUI**. Designed following Apple's Human Interface Guidelines (HIG) with fluid animations, macOS translucent materials, and an extensible architecture.

![macOS 14.0+](https://img.shields.io/badge/macOS-14.0%2B-blue?logo=apple)
![Swift 5.9+](https://img.shields.io/badge/Swift-5.9%2B-orange?logo=swift)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

---

## ✨ Features

### 1. ⏱ Modifiable Timers
* **Customizable Durations**: Tailor durations for **Focus** (default: 25 min), **Short Break** (default: 5 min), and **Long Break** (default: 15 min).
* **Configurable Cycle Interval**: Set how many focus sessions trigger a long break (default: 4 sessions).
* **One-Click Presets**: Quickly toggle between *Classic (25/5/15)*, *Deep Focus (50/10/20)*, and *Quick Sprint (15/3/10)*.
* **Smooth Circular Progress Ring**: Animated timer ring with phase-adaptive gradients, pulsing glow effects, and crisp monospaced digital readout.

### 2. ⚡ Dual Timer Modes
* **Normal Mode**:
  * Counts down to `00:00`, delivers a completion alert and sound, then stops and awaits your explicit interaction to proceed.
* **Progressive Mode (Flow)**:
  * Automatically transitions into the next phase (e.g. Focus ➔ Short Break ➔ Focus ➔ Long Break) while logging the completed session in the background.
  * Includes a configurable countdown buffer (default: 3s) so you can review session transitions seamlessly.

### 3. 🔔 Native macOS Alerts & Audio
* **Actionable Notification Banners**: Delivers native macOS notifications via `UserNotifications` with customized titles, congratulatory messages, and direct action buttons (*"Start Next Phase"*, *"Dismiss"*).
* **Distinct Built-In System Sounds**: Choose from native macOS audio cues (`Glass`, `Ping`, `Hero`, `Blow`, `Purr`, `Submarine`, `Sosumi`, `Morse`, `Tink`, `Pop`, `Basso`) with a built-in sound preview tester.

### 4. 📋 Integrated Task Manager
* **Task Management**: Create, edit, prioritize, and check off tasks with notes and estimated Pomodoros.
* **Active Task Linkage**: Select an active focus task right from the timer screen or task list.
* **Automatic Progress Tracking**: Completing a focus session automatically increments the active task's completed Pomodoro count (`🍅 2/4`).
* **Filters**: View `All`, `Active`, or `Completed` tasks at a glance.

### 5. 📊 Daily Progress Logger & Manual Entry
* **Automatic Session Recording**: Completed focus sessions and breaks are timestamped and saved locally in clean JSON format.
* **Daily Metrics Dashboard**: Real-time stats showing today's completed focus sessions, progress toward your daily goal, and total focus time.
* **Manual Entry (`+` Button)**: Log past or unrecorded sessions with custom dates, durations, session types, and task labels.
* **Quick Session Count Adjuster**: Instant `[-]` and `[+]` buttons to increment or decrement today's completed session tally directly.
* **Privacy-First Local Storage**: All data resides in `~/Library/Application Support/PomodoroClock/`.

### 6. 📅 Streak Calendar & Analytics
* **Monthly Calendar Grid**: An interactive calendar view highlighting days with completed focus sessions using density-based badges.
* **Streak Tracking**:
  * **Current Streak**: Tracks consecutive active days (intelligently preserves your streak when starting a new day).
  * **Best Streak**: All-time record streak.
  * **All-Time Stats**: Total focus hours and all-time session count.
* **Day Inspection Panel**: Click any day on the monthly grid to inspect the exact sessions and tasks completed on that date.

---

## 🏗 Architecture & Code Structure

The project follows a clean **MVVM (Model-View-ViewModel)** architecture and is modularized into `PomodoroCore` and `PomodoroApp`:

```
pomodoro_clock/
├── Package.swift                     # Swift Package definition
├── Makefile                          # Convenient build & test targets
├── scripts/
│   ├── build_app.sh                  # Builds standalone signed Pomodoro.app
│   ├── run.sh                        # Builds and launches the application
│   └── generate_icons.sh             # Generates AppIcon.icns & AppIcon.png
├── Resources/
│   ├── Info.plist                    # macOS Application bundle metadata
│   ├── AppIcon.icns                  # Multi-resolution macOS icon bundle
│   └── AppIcon.png                   # High-res 1024x1024 icon asset
├── Sources/
│   ├── PomodoroCore/                 # Core framework (business logic & UI)
│   │   ├── Models/
│   │   │   ├── SessionType.swift     # Focus, Short Break, Long Break
│   │   │   ├── TimerMode.swift       # Normal vs Progressive modes
│   │   │   ├── TaskItem.swift        # Task data model
│   │   │   ├── PomodoroSession.swift # Completed session record
│   │   │   └── AppSettings.swift     # User preferences & durations
│   │   ├── Services/
│   │   │   ├── StorageService.swift  # Atomic JSON persistence
│   │   │   ├── SoundManager.swift    # AppKit NSSound audio service
│   │   │   └── NotificationManager.swift # UserNotifications integration
│   │   ├── ViewModels/
│   │   │   ├── TimerViewModel.swift  # Pomodoro state machine & timer engine
│   │   │   ├── TaskViewModel.swift   # Task CRUD & active task coordination
│   │   │   ├── ProgressViewModel.swift # Daily metrics & manual logging
│   │   │   └── StreakViewModel.swift # Calendar math & streak calculation
│   │   ├── Views/
│   │   │   ├── MainView.swift        # Root NavigationSplitView
│   │   │   ├── SidebarView.swift     # Navigation sidebar with live badges
│   │   │   ├── Timer/                # Circular progress ring, task picker
│   │   │   ├── Tasks/                # Task list, task row, task editor
│   │   │   ├── Progress/             # Daily progress dashboard, manual log sheet
│   │   │   ├── Calendar/             # Streak calendar grid, day details
│   │   │   └── Settings/             # Preferences & sound preview
│   │   └── Utilities/
│   │       ├── DateExtensions.swift
│   │       ├── ColorExtensions.swift
│   │       └── ViewState.swift       # Safe state wrapper for clean compilation
│   ├── PomodoroApp/
│   │   └── PomodoroApp.swift         # @main macOS Application Entry Point
│   └── PomodoroTests/
│       └── main.swift                # Comprehensive automated unit test suite
└── Tests/
```

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Space` | Start / Pause Timer |
| `⌘ + R` | Reset Current Session |
| `⌘ + S` | Skip to Next Phase |
| `Return` | Quick-add task from input field |
| `Esc` | Dismiss active sheets |

---

## 🚀 Getting Started

### Prerequisites
* macOS 14.0 (Sonoma) or later
* Swift 5.9+ / Xcode or Command Line Tools

### 1. Build & Run Standalone Application Bundle (`Pomodoro.app`)
To build the native macOS `.app` bundle with application icons and code signature:

```bash
make app
open Pomodoro.app
```
Or run the all-in-one script:
```bash
./scripts/run.sh
```

### 2. Build via Swift Package Manager (CLI)
```bash
make build
make run
```

### 3. Run the Automated Unit Test Suite
To verify all 6 features and run the automated test suite:

```bash
make test
```
The test suite validates:
* Timer phase transitions and interval logic
* Normal vs Progressive mode state engine
* Audio cue and notification configurations
* Task creation, editing, completion, and active task tracking
* Daily progress logger, manual entry, and quick count adjustment
* Streak calculations (current streak, best streak, and calendar grid math)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE). Contributions, suggestions, and pull requests are warmly welcomed!
