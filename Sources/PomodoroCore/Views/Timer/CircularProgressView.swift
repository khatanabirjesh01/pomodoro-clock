import SwiftUI

public struct CircularProgressView: View {
    let progress: Double
    let timeString: String
    let phase: SessionType
    let isRunning: Bool
    let transitionCountdown: Int?
    
    @ViewState private var pulseAnimation = false
    
    public init(
        progress: Double,
        timeString: String,
        phase: SessionType,
        isRunning: Bool,
        transitionCountdown: Int? = nil
    ) {
        self.progress = progress
        self.timeString = timeString
        self.phase = phase
        self.isRunning = isRunning
        self.transitionCountdown = transitionCountdown
    }
    
    private var phaseGradient: LinearGradient {
        switch phase {
        case .focus:
            return LinearGradient(
                colors: [Color.red, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .shortBreak:
            return LinearGradient(
                colors: [Color.teal, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .longBreak:
            return LinearGradient(
                colors: [Color.blue, Color.indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color.secondary.opacity(0.18), lineWidth: 16)
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(min(max(progress, 0.0), 1.0)))
                .stroke(
                    phaseGradient,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.25), value: progress)
            
            // Inner content
            VStack(spacing: 8) {
                // Phase icon + badge
                HStack(spacing: 6) {
                    Image(systemName: phase.iconName)
                        .font(.system(size: 14, weight: .bold))
                    Text(phase.rawValue.uppercased())
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(1.5)
                }
                .foregroundStyle(phaseGradient)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.accent(for: phase).opacity(0.12))
                )
                
                // Digital clock readout
                Text(timeString)
                    .font(.system(size: 58, weight: .medium, design: .monospaced))
                    .contentTransition(.numericText())
                    .foregroundStyle(.primary)
                
                // Optional transition message in progressive mode
                if let count = transitionCountdown, count > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11))
                        Text("Auto-advancing in \(count)s...")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.orange)
                    .transition(.opacity)
                }
            }
        }
        .frame(width: 280, height: 280)
        .padding(20)
    }
}
