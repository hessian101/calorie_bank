import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var initialWeight = ""
    @State private var targetWeight = ""
    @State private var currentPage = 0

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                // ページ1: ようこそ
                welcomePage
                    .tag(0)

                // ページ2: プロフィール入力
                profilePage
                    .tag(1)

                // ページ3: 目標設定
                goalPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
        }
        .background(
            LinearGradient(
                colors: [Color.green.opacity(0.1), Color.blue.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    // MARK: - ようこそページ
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🏦")
                .font(.system(size: 80))

            Text("カロリーバンクへようこそ")
                .font(.title)
                .fontWeight(.bold)

            Text("運動で貯めたカロリーを\n好きなものに使おう！")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("はじめる")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - プロフィールページ
    private var profilePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("👤")
                .font(.system(size: 60))

            Text("プロフィール設定")
                .font(.title2)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("ニックネーム", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)

                HStack {
                    TextField("現在の体重", text: $initialWeight)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                    Text("kg")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                withAnimation { currentPage = 2 }
            } label: {
                Text("次へ")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!name.isEmpty && !initialWeight.isEmpty ? Color.green : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(name.isEmpty || initialWeight.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    // MARK: - 目標設定ページ
    private var goalPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🎯")
                .font(.system(size: 60))

            Text("目標を設定しよう")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                TextField("目標体重", text: $targetWeight)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                Text("kg")
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)

            if let initial = Double(initialWeight), let target = Double(targetWeight), target < initial {
                let diff = initial - target
                Text("目標: \(String(format: "%.1f", diff))kg 減量")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .fontWeight(.semibold)
            }

            Spacer()

            Button {
                saveProfile()
            } label: {
                Text("スタート！")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!targetWeight.isEmpty ? Color.green : Color.gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(targetWeight.isEmpty)
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }

    private func saveProfile() {
        guard let weight = Double(initialWeight),
              let target = Double(targetWeight) else { return }

        let profile = UserProfile(
            name: name,
            initialWeight: weight,
            targetWeight: target
        )
        modelContext.insert(profile)
        onComplete()
    }
}
