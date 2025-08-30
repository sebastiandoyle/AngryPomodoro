import Foundation
import Combine
import UIKit

final class TimerViewModel: ObservableObject {
    // User-configurable durations (minutes)
    @Published var workDurationMinutes: Double = 25
    @Published var breakDurationMinutes: Double = 5
    @Published var requireFaceDown: Bool = true

    // Timer state
    @Published private(set) var isRunning: Bool = false
    @Published private(set) var isWorkSession: Bool = true
    @Published var timeRemainingSeconds: Int = 25 * 60

    // Device state
    @Published private(set) var isFaceDown: Bool = false
    @Published private(set) var lastViolationDescription: String? = nil

    // Enforcement arming: only enforce after first face-down since Start
    @Published private(set) var isEnforcementArmed: Bool = false

    // Visual flashing overlay state
    @Published private(set) var isFlashingTomatoes: Bool = false
    @Published private(set) var currentTomatoIndex: Int = 0 // 0 or 1

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var tomatoFlashTimer: DispatchSourceTimer?

    private let motionMonitor = MotionMonitor()
    private let violationManager = ViolationManager()

    private var isRunningUnderTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    init() {
        // Observe face-down changes
        motionMonitor.isFaceDownPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] faceDown in
                guard let self else { return }
                self.isFaceDown = faceDown
                // Arm on first face-down after starting a work session
                if self.isRunning && self.isWorkSession && self.requireFaceDown && !self.isEnforcementArmed && faceDown {
                    self.isEnforcementArmed = true
                    self.lastViolationDescription = "Armed: stay face-down during work"
                }
                // If compliance is restored while alerts are active, stop them immediately
                if faceDown {
                    self.violationManager.stopAll()
                    self.stopTomatoFlashing()
                }
            }
            .store(in: &cancellables)

        // Keep time remaining in sync with chosen durations when idle
        $workDurationMinutes
            .combineLatest($breakDurationMinutes)
            .sink { [weak self] w, b in
                guard let self else { return }
                if !self.isRunning {
                    self.timeRemainingSeconds = Int((self.isWorkSession ? w : b) * 60)
                }
            }
            .store(in: &cancellables)
    }

    var formattedTimeRemaining: String {
        let minutes = timeRemainingSeconds / 60
        let seconds = timeRemainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }

    func resetTimer() {
        pauseTimer()
        isWorkSession = true
        isEnforcementArmed = false
        timeRemainingSeconds = Int(workDurationMinutes * 60)
        lastViolationDescription = nil
    }

    private func startTimer() {
        if timeRemainingSeconds <= 0 {
            timeRemainingSeconds = Int((isWorkSession ? workDurationMinutes : breakDurationMinutes) * 60)
        }
        isRunning = true
        // Disarm enforcement at start; user can press Start while phone is up
        isEnforcementArmed = false
        if !isRunningUnderTests {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        motionMonitor.start()
        scheduleTickTimer()
    }

    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        if !isRunningUnderTests {
            UIApplication.shared.isIdleTimerDisabled = false
        }
        motionMonitor.stop()
        violationManager.stopAll()
        stopTomatoFlashing()
    }

    private func scheduleTickTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleTick()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private var violationCooldownActive: Bool = false

    private func handleTick() {
        guard isRunning else { return }

        // Face-down requirement enforcement during work
        if isWorkSession && requireFaceDown {
            // Only enforce after the session is armed by first face-down
            if isEnforcementArmed {
                if !isFaceDown {
                    triggerViolationIfNeeded(reason: "Picked up during work – busted!")
                }
            }
        }

        if timeRemainingSeconds > 0 {
            timeRemainingSeconds -= 1
        } else {
            nextSession()
        }
    }

    private func nextSession() {
        isWorkSession.toggle()
        let next = isWorkSession ? workDurationMinutes : breakDurationMinutes
        timeRemainingSeconds = Int(next * 60)
        lastViolationDescription = nil
        violationManager.stopAll()
        stopTomatoFlashing()
        // At the start of a new work session, disarm enforcement until face-down
        isEnforcementArmed = isWorkSession ? false : false
    }

    private func triggerViolationIfNeeded(reason: String) {
        // Debounce violations to avoid spamming every tick
        guard !violationCooldownActive else { return }
        violationCooldownActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.violationCooldownActive = false
        }

        lastViolationDescription = reason
        violationManager.triggerObnoxiousAlert()
        startTomatoFlashing(forSeconds: 5)
    }

    private func startTomatoFlashing(forSeconds seconds: TimeInterval) {
        stopTomatoFlashing()
        isFlashingTomatoes = true
        currentTomatoIndex = 0
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now(), repeating: .milliseconds(80)) // ~12.5 Hz alternation
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.currentTomatoIndex = 1 - self.currentTomatoIndex
        }
        tomatoFlashTimer = timer
        timer.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            self?.stopTomatoFlashing()
        }
    }

    private func stopTomatoFlashing() {
        tomatoFlashTimer?.cancel()
        tomatoFlashTimer = nil
        isFlashingTomatoes = false
    }
}
