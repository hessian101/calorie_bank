import SwiftUI

struct StreakView: View {
    var streakDays: Int

    private var streakColor: Color {
        if streakDays >= 30 { return .red }
        if streakDays >= 14 { return .orange }
        if streakDays >= 7 { return .yellow }
        return .green
    }

    private var streakMessage: String {
        if streakDays >= 30 { return "すごい！1ヶ月継続中！" }
        if streakDays >= 14 { return "2週間突破！絶好調！" }
        if streakDays >= 7 { return "1週間達成！" }
        if streakDays >= 3 { return "いい調子！" }
        if streakDays >= 1 { return "継続は力なり！" }
        return "今日から始めよう！"
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(streakColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                VStack(spacing: 0) {
                    Text("🔥")
                        .font(.system(size: 20))
                    Text("\(streakDays)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(streakColor)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streakDays)日間継続中")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(streakMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakView(streakDays: 0)
        StreakView(streakDays: 3)
        StreakView(streakDays: 7)
        StreakView(streakDays: 14)
        StreakView(streakDays: 30)
    }
    .padding()
}
