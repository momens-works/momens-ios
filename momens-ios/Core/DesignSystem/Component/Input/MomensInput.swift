import SwiftUI

struct MomensInput<TrailingContent: View>: View {
    @Binding private var text: String
    private let placeholder: String
    private let trailingContent: TrailingContent

    init(
        text: Binding<String>,
        placeholder: String,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        _text = text
        self.placeholder = placeholder
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(MomensColor.gray300)
            )
            .momensFont(.bodyM14)
            .foregroundStyle(MomensColor.gray800)
            .textFieldStyle(.plain)
            .frame(minHeight: 21)
            .accessibilityLabel(placeholder)

            trailingContent
        }
        .padding(.vertical, 6)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(MomensColor.gray300)
                .frame(height: 1)
        }
    }
}

extension MomensInput where TrailingContent == EmptyView {
    init(text: Binding<String>, placeholder: String) {
        self.init(text: text, placeholder: placeholder) {
            EmptyView()
        }
    }
}

#Preview("MomensInput - Large Default and Active") {
    VStack(spacing: 20) {
        MomensInput(text: .constant(""), placeholder: "Example")
        MomensInput(text: .constant("Write"), placeholder: "Example")
    }
    .frame(width: 343)
    .padding(16)
}
