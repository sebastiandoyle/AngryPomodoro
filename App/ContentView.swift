import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var timer: TimerViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text(timer.isWorkSession ? "Work" : "Break")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundStyle(timer.isWorkSession ? .red : .green)
                    Text(timer.formattedTimeRemaining)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                }
                .padding(.top, 32)

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Stepper("Work: \(Int(timer.workDurationMinutes)) min", value: $timer.workDurationMinutes, in: 10...60, step: 5)
                        Stepper("Break: \(Int(timer.breakDurationMinutes)) min", value: $timer.breakDurationMinutes, in: 3...30, step: 1)
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                    Toggle(isOn: $timer.requireFaceDown) {
                        Text("Require face-down during work")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .red))
                }
                .padding(.horizontal)

                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Button(action: { timer.toggleTimer() }) {
                            Text(timer.isRunning ? "Pause" : "Start")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(timer.isRunning ? Color.orange : Color.red)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        Button(action: { timer.resetTimer() }) {
                            Text("Reset")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundStyle(.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                    }

                    if timer.isWorkSession && timer.requireFaceDown {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 10, height: 10)
                            Text(statusText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let lastViolation = timer.lastViolationDescription {
                        Text(lastViolation)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 8)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(colors: [.black, .gray.opacity(0.2)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )

            if timer.isFlashingTomatoes {
                FlashingOverlay(currentIndex: timer.currentTomatoIndex)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
    }

    private var statusText: String {
        if !timer.isRunning { return "Press Start, then put the phone face-down" }
        if !timer.isEnforcementArmed { return "Arming: put the phone face-down to begin enforcement" }
        return timer.isFaceDown ? "Armed: screen down (good)" : "Violation if not down (stay down!)"
    }

    private var statusColor: Color {
        if !timer.isRunning { return .yellow }
        if !timer.isEnforcementArmed { return .yellow }
        return timer.isFaceDown ? .green : .red
    }
}

private struct FlashingOverlay: View {
    let currentIndex: Int

    var body: some View {
        ZStack {
            Color.white
            loadedImage
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .overlay(Color.red.opacity(0.25).blendMode(.multiply))
        }
    }

    private var loadedImage: Image {
        let name = currentIndex == 0 ? "Tomato 1" : "Tomato 2"
        if let url = Bundle.main.url(forResource: name, withExtension: "png"),
           let ui = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: ui)
        }
        // Fallback if images aren't found for any reason
        return Image(systemName: "exclamationmark.triangle.fill")
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerViewModel())
}
