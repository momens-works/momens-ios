import SwiftUI

struct TaskEditCompletionRuleBox: View {
    @Binding var text: String
    @Binding var isChecked: Bool

    let onDeleteTap: () -> Void

    @FocusState private var isTextFocused: Bool

    private var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(MomensColor.gray200)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 3)
                .accessibilityHidden(true)

            HStack(spacing: 8) {
                Button {
                    isChecked.toggle()
                } label: {
                    Image(decorative: isChecked ? "ic_checkbox_fill" : "ic_checkbox_empty")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(isChecked ? MomensColor.primary50 : MomensColor.gray300)
                }
                .buttonStyle(MomensButtonStyle())
                .disabled(isEmpty)
                .accessibilityLabel("완료 조건")
                .accessibilityValue(isChecked ? "완료" : "미완료")

                TextField(
                    "",
                    text: $text,
                    prompt: Text("완료 기준을 기재해주세요")
                        .foregroundStyle(MomensColor.gray300),
                    axis: .vertical
                )
                .textFieldStyle(.plain)
                .momensFont(.bodyM12)
                .foregroundStyle(MomensColor.gray800)
                .tint(MomensColor.gray800)
                .focused($isTextFocused)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("완료 조건 내용")

                Spacer(minLength: 0)
            }

            Button {
                isTextFocused = false
                onDeleteTap()
            } label: {
                Image(decorative: "ic_cancel")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundStyle(MomensColor.gray900)
            }
            .buttonStyle(MomensButtonStyle())
            .accessibilityLabel("완료 조건 삭제")
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .background(
            MomensColor.gray100,
            in: RoundedRectangle(cornerRadius: 8)
        )
        .onChange(of: isEmpty) { _, isEmpty in
            if isEmpty {
                isChecked = false
            }
        }
    }
}

private struct TaskEditCompletionRuleBoxPreview: View {
    private struct Rule: Identifiable, Equatable {
        let id = UUID()
        var text = ""
        var isChecked = false
    }

    @State private var rules: [Rule] = [Rule()]

    var body: some View {
        VStack(spacing: 12) {
            ForEach($rules) { $rule in
                let ruleID = rule.id

                TaskEditCompletionRuleBox(
                    text: $rule.text,
                    isChecked: $rule.isChecked,
                    onDeleteTap: {
                        rules.removeAll { $0.id == ruleID }
                    }
                )
            }
        }
        .frame(width: 343)
        .padding(20)
    }
}

#Preview("Completion Rule Box") {
    TaskEditCompletionRuleBoxPreview()
}
