import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(EntitlementManager.self) private var entitlementManager
    @State private var viewModel = StudyViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                categoryPicker
                quizEntryButton
                content
            }
            .navigationTitle("Study")
            .task {
                viewModel.loadQuestions(context: modelContext)
            }
            .onChange(of: viewModel.selectedCategory) {
                viewModel.loadQuestions(context: modelContext)
            }
        }
    }

    private var categoryPicker: some View {
        Picker("Category", selection: $viewModel.selectedCategory) {
            Text("All").tag(StudyCategory?.none)
            ForEach(StudyCategory.allCases) { category in
                Text(category.rawValue).tag(Optional(category))
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, CPSpacing.md)
        .padding(.top, CPSpacing.sm)
    }

    private var quizEntryButton: some View {
        NavigationLink {
            QuizView()
        } label: {
            HStack {
                Image(systemName: "bolt.fill")
                Text("Take a Mock Quiz")
                Spacer()
                Image(systemName: "chevron.right")
            }
            .font(CPTypography.body.bold())
            .foregroundStyle(.white)
            .padding(CPSpacing.md)
            .background(CPColor.brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.horizontal, CPSpacing.md)
        .padding(.vertical, CPSpacing.sm)
    }

    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage {
            ContentUnavailableView(
                "Couldn't Load Questions",
                systemImage: "exclamationmark.triangle",
                description: Text(errorMessage)
            )
        } else if AccessGate.isLocked(viewModel.selectedCategory, hasPremiumAccess: entitlementManager.hasPremiumAccess) {
            PaywallView()
        } else if visibleQuestions.isEmpty {
            ContentUnavailableView(
                "No Questions Yet",
                systemImage: "book.closed"
            )
        } else {
            List {
                if showsUpgradeBanner {
                    upgradeBanner
                        .listRowInsets(EdgeInsets(top: CPSpacing.xs, leading: CPSpacing.md, bottom: CPSpacing.xs, trailing: CPSpacing.md))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                ForEach(visibleQuestions, id: \.id) { question in
                    QuestionCardView(question: question)
                        .listRowInsets(EdgeInsets(top: CPSpacing.xs, leading: CPSpacing.md, bottom: CPSpacing.xs, trailing: CPSpacing.md))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(CPColor.background)
        }
    }

    /// "All" never reveals locked-category content to free users — it's quietly
    /// narrowed to the free category rather than leaking premium questions.
    private var visibleQuestions: [Question] {
        guard viewModel.selectedCategory == nil, !entitlementManager.hasPremiumAccess else {
            return viewModel.questions
        }
        return viewModel.questions.filter { $0.category == AccessGate.freeCategory }
    }

    private var showsUpgradeBanner: Bool {
        viewModel.selectedCategory == nil && !entitlementManager.hasPremiumAccess
    }

    private var upgradeBanner: some View {
        NavigationLink {
            PaywallView()
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                Text("Unlock American History & Integrated Civics")
                    .font(CPTypography.caption)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundStyle(CPColor.brandAccent)
            .padding(CPSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(CPColor.brandAccent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct QuestionCardView: View {
    let question: Question
    @State private var selectedOptionIndex: Int?
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: CPSpacing.xs) {
                        HStack(spacing: CPSpacing.xs) {
                            Text(question.category.rawValue)
                                .font(CPTypography.caption)
                                .foregroundStyle(.secondary)
                            DifficultyBadge(difficulty: question.difficulty)
                        }
                        Text(question.questionText)
                            .font(CPTypography.body)
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: CPSpacing.xs) {
                    ForEach(question.options.indices, id: \.self) { index in
                        AnswerOptionButton(
                            text: question.options[index],
                            isSelected: selectedOptionIndex == index,
                            isCorrectAnswer: index == question.correctAnswerIndex,
                            isRevealed: selectedOptionIndex != nil
                        ) {
                            guard selectedOptionIndex == nil else { return }
                            selectedOptionIndex = index
                        }
                    }

                    if selectedOptionIndex != nil, let explanation = question.explanation {
                        Text(explanation)
                            .font(CPTypography.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, CPSpacing.xs)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(CPSpacing.md)
        .background(CPColor.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    StudyView()
        .modelContainer(PersistenceController.previewModelContainer)
        .environment(EntitlementManager())
}
