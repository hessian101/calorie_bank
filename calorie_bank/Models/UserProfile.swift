import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var initialWeight: Double
    var targetWeight: Double
    var createdAt: Date

    init(name: String, initialWeight: Double, targetWeight: Double) {
        self.name = name
        self.initialWeight = initialWeight
        self.targetWeight = targetWeight
        self.createdAt = Date()
    }
}
