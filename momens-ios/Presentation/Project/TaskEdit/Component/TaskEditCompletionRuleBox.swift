import SwiftUI

struct TaskEditCompletionRuleBox: View {
    @Binding var text: String
    @Binding var isChecked: Bool

    let onDeleteTap: () -> Void
    let onDragStart: () -> Void
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: () -> Void

    @FocusState private var isTextFocused: Bool

    private var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var limitedText: Binding<String> {
        Binding(
            get: { text },
            set: { text = String($0.prefix(50)) }
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            TaskEditDragHandle(
                onDragStart: {
                    isTextFocused = false
                    onDragStart()
                },
                onDragChanged: onDragChanged,
                onDragEnded: onDragEnded
            )

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

                TextField(
                    "",
                    text: limitedText,
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

#Preview("Completion Rule Box - Drag Handle"){
    @Previewable @State var text = ""
    @Previewable @State  var isChecked = false
    @Previewable @State  var isVisible = true
    @Previewable @State  var dragOffset: CGSize = .zero

    VStack {
        if isVisible {
            TaskEditCompletionRuleBox(
                text: $text,
                isChecked: $isChecked,
                onDeleteTap: {
                    isVisible = false
                },
                onDragStart: {
                    dragOffset = .zero
                },
                onDragChanged: { translation in
                    dragOffset = translation
                },
                onDragEnded: {
                    dragOffset = .zero
                }
            )
            .offset(y: dragOffset.height)
        }
    }
    .frame(width: 343)
    .frame(minHeight: 200)
    .padding(20)
}
