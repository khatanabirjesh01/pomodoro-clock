// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PomodoroApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "PomodoroCore",
            targets: ["PomodoroCore"]
        ),
        .executable(
            name: "PomodoroApp",
            targets: ["PomodoroApp"]
        ),
        .executable(
            name: "PomodoroTests",
            targets: ["PomodoroTests"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PomodoroCore",
            dependencies: [],
            path: "Sources/PomodoroCore"
        ),
        .executableTarget(
            name: "PomodoroApp",
            dependencies: ["PomodoroCore"],
            path: "Sources/PomodoroApp"
        ),
        .executableTarget(
            name: "PomodoroTests",
            dependencies: ["PomodoroCore"],
            path: "Sources/PomodoroTests"
        )
    ]
)
