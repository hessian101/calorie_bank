import SwiftUI
import SwiftData

@main
struct calorie_bankApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [UserProfile.self, CalorieTransaction.self])
    }
}
