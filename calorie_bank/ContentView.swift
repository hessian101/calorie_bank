import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]
    @State private var hasCompletedOnboarding = false

    var body: some View {
        if profiles.isEmpty && !hasCompletedOnboarding {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        } else {
            TabView {
                Tab("ホーム", systemImage: "house.fill") {
                    HomeView()
                }

                Tab("履歴", systemImage: "clock.fill") {
                    HistoryView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProfile.self, CalorieTransaction.self], inMemory: true)
}
