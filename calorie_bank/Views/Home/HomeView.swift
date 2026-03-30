import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \CalorieTransaction.date, order: .reverse) private var transactions: [CalorieTransaction]

    @State private var showDeposit = false
    @State private var showWithdraw = false

    private var profile: UserProfile? { profiles.first }

    // 合計貯金額
    private var totalBalance: Double {
        let deposits = transactions.filter { $0.type == .deposit }.reduce(0) { $0 + $1.amount }
        let withdrawals = transactions.filter { $0.type == .withdrawal }.reduce(0) { $0 + $1.amount }
        return deposits - withdrawals
    }

    // 目標に対する進捗（0.0〜1.0）
    private var progress: Double {
        guard let profile else { return 0 }
        let weightDiff = profile.initialWeight - profile.targetWeight
        guard weightDiff > 0 else { return 0 }
        // 7,200kcal ≈ 1kg 減量の目安
        let targetCalories = weightDiff * 7200
        return min(totalBalance / targetCalories, 1.0)
    }

    // ストリーク日数計算
    private var streakDays: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // 今日の記録があるか確認
        let todayTransactions = transactions.filter {
            calendar.isDate($0.date, inSameDayAs: checkDate)
        }
        if todayTransactions.isEmpty && !transactions.isEmpty {
            // 今日記録がなければ昨日から数える
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        while true {
            let dayTransactions = transactions.filter {
                calendar.isDate($0.date, inSameDayAs: checkDate)
            }
            if dayTransactions.isEmpty { break }
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }

        return streak
    }

    // モチベーションメッセージ
    private var motivationMessage: String {
        let todayDeposits = todayDepositAmount
        let todayWithdrawals = todayWithdrawalAmount

        if todayDeposits > 800 {
            return "⚠️ 頑張りすぎ注意！体を休めることも大切です"
        }
        if todayWithdrawals > todayDeposits && todayWithdrawals > 500 {
            return "💡 少し食べすぎかも？軽い運動で取り戻そう！"
        }
        if todayDeposits > 0 && totalBalance > 0 {
            return "✨ いい調子！コツコツ貯めていこう！"
        }
        if totalBalance < 0 {
            return "💪 赤字だけど大丈夫！少しずつ取り戻そう"
        }
        return "🌟 今日も1日頑張ろう！"
    }

    private var todayDepositAmount: Double {
        let calendar = Calendar.current
        return transactions
            .filter { $0.type == .deposit && calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var todayWithdrawalAmount: Double {
        let calendar = Calendar.current
        return transactions
            .filter { $0.type == .withdrawal && calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 貯金額表示
                    balanceCard

                    // アバター
                    AvatarView(progress: progress)
                        .frame(height: 200)

                    // モチベーションメッセージ
                    Text(motivationMessage)
                        .font(.subheadline)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)

                    // ストリーク
                    StreakView(streakDays: streakDays)
                        .padding(.horizontal)

                    // 今日の記録サマリー
                    todaySummary

                    // 入金・出金ボタン
                    actionButtons
                }
                .padding(.vertical)
            }
            .navigationTitle("カロリーバンク")
            .sheet(isPresented: $showDeposit) {
                DepositView()
            }
            .sheet(isPresented: $showWithdraw) {
                WithdrawView()
            }
        }
    }

    // MARK: - 貯金額カード
    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("貯金残高")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(totalBalance >= 0 ? "+" : "")
                    .font(.title2)
                    .foregroundStyle(totalBalance >= 0 ? .green : .red)
                Text("\(Int(totalBalance))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(totalBalance >= 0 ? .green : .red)
                    .contentTransition(.numericText())
                Text("kcal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            if let profile {
                ProgressView(value: max(progress, 0), total: 1.0)
                    .tint(.green)
                    .padding(.horizontal, 32)

                Text("目標達成率: \(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    // MARK: - 今日のサマリー
    private var todaySummary: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("今日の入金")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("+\(Int(todayDepositAmount))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 4) {
                Text("今日の出金")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("-\(Int(todayWithdrawalAmount))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    // MARK: - アクションボタン
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                showDeposit = true
            } label: {
                Label("入金（運動）", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                showWithdraw = true
            } label: {
                Label("出金（食事）", systemImage: "minus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal)
    }
}
