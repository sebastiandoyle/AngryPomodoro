import SwiftUI

@main
struct AngryPomodoroApp: App {
    @StateObject private var timerViewModel = TimerViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(timerViewModel)
        }
    }
}

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            OnboardingView()
        }
    }
}
