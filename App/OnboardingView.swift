import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            VStack(spacing: 12) {
                Text("Angry Pomodoro")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
                Text("Get scared productive")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 16) {
                BenefitRow(emoji: "💥", title: "Harsh accountability", subtitle: "Pick it up during work and you'll get roasted by a scream and flashing lights.")
                BenefitRow(emoji: "📵", title: "Face-down focus", subtitle: "Put the screen down and let your brain do deep work.")
                BenefitRow(emoji: "⏱️", title: "Classic Pomodoro", subtitle: "Customizable work/break intervals with a sleek, minimal UI.")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

            Spacer()
            Button(action: {
                PermissionsManager.shared.requestCameraIfNeeded { _ in
                    hasCompletedOnboarding = true
                }
            }) {
                Text("I'm ready. Be mean.")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 8)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding()
        .background(
            ZStack {
                LinearGradient(colors: [.black, .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                AngularGradient(gradient: Gradient(colors: [.red.opacity(0.4), .clear]), center: .topLeading)
            }
            .ignoresSafeArea()
        )
    }
}

private struct BenefitRow: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji).font(.largeTitle)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
