import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalorieTransaction.date, order: .reverse) private var transactions: [CalorieTransaction]

    @State private var filterType: FilterType = .all

    enum FilterType: String, CaseIterable {
        case all = "すべて"
        case deposits = "入金"
        case withdrawals = "出金"
    }

    private var filteredTransactions: [CalorieTransaction] {
        switch filterType {
        case .all: return transactions
        case .deposits: return transactions.filter { $0.type == .deposit }
        case .withdrawals: return transactions.filter { $0.type == .withdrawal }
        }
    }

    // 日付ごとにグループ化
    private var groupedTransactions: [(String, [CalorieTransaction])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")

        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formatter.string(from: transaction.date)
        }

        return grouped.sorted { lhs, rhs in
            guard let lhsDate = lhs.value.first?.date, let rhsDate = rhs.value.first?.date else { return false }
            return lhsDate > rhsDate
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // フィルター
                Picker("フィルター", selection: $filterType) {
                    ForEach(FilterType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredTransactions.isEmpty {
                    ContentUnavailableView(
                        "記録がありません",
                        systemImage: "tray",
                        description: Text("運動や食事を記録すると\nここに表示されます")
                    )
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.0) { dateString, dayTransactions in
                            Section(dateString) {
                                ForEach(dayTransactions, id: \.id) { transaction in
                                    transactionRow(transaction)
                                }
                                .onDelete { indexSet in
                                    deleteTransactions(dayTransactions: dayTransactions, at: indexSet)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("履歴")
        }
    }

    private func transactionRow(_ transaction: CalorieTransaction) -> some View {
        HStack {
            Circle()
                .fill(transaction.type == .deposit ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: transaction.type == .deposit ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundStyle(transaction.type == .deposit ? .green : .orange)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(transaction.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(transaction.type == .deposit ? "+" : "-")\(Int(transaction.amount)) kcal")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(transaction.type == .deposit ? .green : .orange)
        }
    }

    private func deleteTransactions(dayTransactions: [CalorieTransaction], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(dayTransactions[index])
        }
    }
}
