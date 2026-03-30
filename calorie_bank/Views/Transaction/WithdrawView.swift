import SwiftUI
import SwiftData

struct WithdrawView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var customTitle = ""
    @State private var customCalories = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    VStack(spacing: 8) {
                        Text("🍰")
                            .font(.system(size: 48))
                        Text("貯金から引き出して\n罪悪感なく楽しもう！")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // プリセット一覧
                    VStack(alignment: .leading, spacing: 12) {
                        Text("プリセットから選択")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(CaloriePresets.foods) { preset in
                                presetButton(preset)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()
                        .padding(.horizontal)

                    // カスタム入力
                    VStack(alignment: .leading, spacing: 12) {
                        Text("カスタム入力")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)

                        TextField("食べ物の内容", text: $customTitle)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)

                        HStack {
                            TextField("カロリー", text: $customCalories)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            Text("kcal")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)

                        Button {
                            saveCustom()
                        } label: {
                            Text("出金する")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canSaveCustom ? Color.orange : Color.gray)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(!canSaveCustom)
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("カロリー出金")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    private var canSaveCustom: Bool {
        !customTitle.isEmpty && Double(customCalories) != nil && Double(customCalories)! > 0
    }

    private func presetButton(_ preset: CaloriePreset) -> some View {
        Button {
            let transaction = CalorieTransaction(
                type: .withdrawal,
                amount: preset.calories,
                title: preset.name
            )
            modelContext.insert(transaction)
            dismiss()
        } label: {
            VStack(spacing: 6) {
                Text(preset.emoji)
                    .font(.system(size: 28))
                Text(preset.name)
                    .font(.caption)
                    .lineLimit(1)
                Text("-\(Int(preset.calories)) kcal")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func saveCustom() {
        guard let calories = Double(customCalories), calories > 0 else { return }
        let transaction = CalorieTransaction(
            type: .withdrawal,
            amount: calories,
            title: customTitle
        )
        modelContext.insert(transaction)
        dismiss()
    }
}
