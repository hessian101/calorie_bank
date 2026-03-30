import Foundation

struct CaloriePreset: Identifiable {
    let id = UUID()
    let name: String
    let calories: Double
    let emoji: String
}

struct CaloriePresets {
    // 運動プリセット（入金）
    static let exercises: [CaloriePreset] = [
        CaloriePreset(name: "ウォーキング 30分", calories: 120, emoji: "🚶"),
        CaloriePreset(name: "ランニング 30分", calories: 250, emoji: "🏃"),
        CaloriePreset(name: "サイクリング 30分", calories: 200, emoji: "🚴"),
        CaloriePreset(name: "水泳 30分", calories: 300, emoji: "🏊"),
        CaloriePreset(name: "筋トレ 30分", calories: 180, emoji: "🏋️"),
        CaloriePreset(name: "ヨガ 30分", calories: 100, emoji: "🧘"),
        CaloriePreset(name: "ダンス 30分", calories: 200, emoji: "💃"),
        CaloriePreset(name: "縄跳び 15分", calories: 150, emoji: "🪢"),
    ]

    // 食べ物プリセット（出金）
    static let foods: [CaloriePreset] = [
        CaloriePreset(name: "おにぎり 1個", calories: 180, emoji: "🍙"),
        CaloriePreset(name: "ケーキ 1切れ", calories: 350, emoji: "🍰"),
        CaloriePreset(name: "チョコレート", calories: 280, emoji: "🍫"),
        CaloriePreset(name: "アイスクリーム", calories: 200, emoji: "🍨"),
        CaloriePreset(name: "ポテトチップス", calories: 340, emoji: "🥔"),
        CaloriePreset(name: "タピオカミルクティー", calories: 400, emoji: "🧋"),
        CaloriePreset(name: "ラーメン", calories: 500, emoji: "🍜"),
        CaloriePreset(name: "ハンバーガー", calories: 450, emoji: "🍔"),
    ]
}
