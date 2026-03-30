import SwiftUI

struct AvatarView: View {
    /// 0.0（太め）〜 1.0（スリム）の進捗度
    var progress: Double

    // 進捗に応じた体の幅スケール（1.0が普通、大きいほど太い）
    private var bodyScale: Double {
        let clamped = min(max(progress, 0), 1)
        return 1.4 - (clamped * 0.5)  // 1.4（太め）→ 0.9（スリム）
    }

    private var bodyColor: Color {
        if progress >= 0.8 { return .green }
        if progress >= 0.5 { return .blue }
        if progress >= 0.3 { return .orange }
        return .red.opacity(0.8)
    }

    private var expressionText: String {
        if progress >= 0.8 { return "😆" }
        if progress >= 0.5 { return "😊" }
        if progress >= 0.3 { return "🙂" }
        return "😤"
    }

    var body: some View {
        VStack(spacing: 4) {
            // 顔
            Text(expressionText)
                .font(.system(size: 44))

            // 体
            ZStack {
                // 胴体
                Ellipse()
                    .fill(bodyColor.gradient)
                    .frame(
                        width: 60 * bodyScale,
                        height: 80
                    )

                // 腕（左）
                Capsule()
                    .fill(bodyColor.gradient)
                    .frame(width: 14, height: 40)
                    .rotationEffect(.degrees(20))
                    .offset(x: -38 * bodyScale, y: -5)

                // 腕（右）
                Capsule()
                    .fill(bodyColor.gradient)
                    .frame(width: 14, height: 40)
                    .rotationEffect(.degrees(-20))
                    .offset(x: 38 * bodyScale, y: -5)
            }

            // 脚
            HStack(spacing: 8 * bodyScale) {
                Capsule()
                    .fill(bodyColor.gradient)
                    .frame(width: 16, height: 45)
                Capsule()
                    .fill(bodyColor.gradient)
                    .frame(width: 16, height: 45)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

#Preview {
    VStack(spacing: 32) {
        HStack(spacing: 40) {
            VStack {
                AvatarView(progress: 0.0)
                Text("開始")
                    .font(.caption)
            }
            VStack {
                AvatarView(progress: 0.5)
                Text("中間")
                    .font(.caption)
            }
            VStack {
                AvatarView(progress: 1.0)
                Text("達成")
                    .font(.caption)
            }
        }
    }
}
