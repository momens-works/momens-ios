import SwiftUI

struct MomensCountInput: View {
    @Binding private var text: String
    private let placeholder: String
    private let maximumCount: Int
    private let isError: Bool

    init(
        text: Binding<String>,
        placeholder: String,
        maximumCount: Int,
        isError: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        self.maximumCount = max(0, maximumCount)
        self.isError = isError
    }

    var body: some View {
        MomensInput(
            text: limitedText,
            placeholder: placeholder
        ) {
            Text("\(text.count)/\(maximumCount)")
                .momensFont(.bodyM12)
                .foregroundStyle(countColor)
                .fixedSize()
        }
    }

    private var countColor: Color {
        if isError {
            MomensColor.pointRed
        } else if text.isEmpty {
            MomensColor.gray300
        } else {
            MomensColor.gray400
        }
    }

    private var limitedText: Binding<String> {
        Binding(
            get: { text },
            set: { text = String($0.prefix(maximumCount)) }
        )
    }
}

#Preview("MomensCountInput - Large") {
    VStack(spacing: 16) {
        MomensCountInput(
            text: .constant(""),
            placeholder: "Title",
            maximumCount: 15
        )
        MomensCountInput(
            text: .constant("Title"),
            placeholder: "Title",
            maximumCount: 15
        )
        MomensCountInput(
            text: .constant("Title"),
            placeholder: "Title",
            maximumCount: 15,
            isError: true
        )
    }
    .frame(width: 343)
    .padding(16)
}

#Preview("MomensCountInput - Small") {
    VStack(spacing: 16) {
        MomensCountInput(
            text: .constant(""),
            placeholder: "Title",
            maximumCount: 15
        )
        MomensCountInput(
            text: .constant("Title"),
            placeholder: "Title",
            maximumCount: 15
        )
        MomensCountInput(
            text: .constant("Title"),
            placeholder: "Title",
            maximumCount: 15,
            isError: true
        )
    }
    .frame(width: 277)
    .padding(16)
}
