import SwiftUI

struct TaskEditCompletionRuleBox: View {
    @Binding var text: String
    @Binding var isChecked: Bool

    let onDeleteTap: () -> Void
    let onDragStart: () -> Void
    let onDragChanged: (CGSize) -> Void
    let onDragEnded: () -> Void

    @State private var isTextFocused = false

    private var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HStack(spacing: 12) {
            TaskEditDragHandle()
                .frame(maxHeight: .infinity)
                .padding(.vertical, 3)
                .frame(width: 24)
                .contentShape(Rectangle())
                .modifier(TaskEditDragHandler(
                    onDragStart: {
                        isTextFocused = false
                        onDragStart()
                    },
                    onDragChanged: onDragChanged,
                    onDragEnded: onDragEnded
                ))

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

                TaskEditCompletionRuleInput(
                    text: $text,
                    isFocused: $isTextFocused
                )
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

#Preview("Completion Rule Box - Drag Handle") {
    @Previewable @State var text = ""
    @Previewable @State var isChecked = false
    @Previewable @State var isVisible = true
    @Previewable @State var dragOffset: CGSize = .zero

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
