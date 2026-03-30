import Foundation
import SwiftData

enum TransactionType: String, Codable {
    case deposit    // 運動（入金）
    case withdrawal // 食事（出金）
}

@Model
final class CalorieTransaction {
    var id: UUID
    var type: TransactionType
    var amount: Double
    var title: String
    var date: Date

    init(type: TransactionType, amount: Double, title: String, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.amount = amount
        self.title = title
        self.date = date
    }
}
