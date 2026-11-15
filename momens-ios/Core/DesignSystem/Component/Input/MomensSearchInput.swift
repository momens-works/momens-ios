import SwiftUI

struct MomensSearchInput: View {
    @Binding private var text: String
    private let placeholder: String
    private let onSearch: () -> Void

    init(
        text: Binding<String>,
        placeholder: String = "",
        onSearch: @escaping () -> Void
    ) {
        _text = text
        self.placeholder = placeholder
        self.onSearch = onSearch
    }

    var body: some View {
        MomensInput(
            text: $text,
            placeholder: placeholder
        ) {
            Button {
                onSearch()
            } label: {
                Image(decorative: "ic_search")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundStyle(MomensColor.gray600)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("검색")
        }
        .submitLabel(.search)
        .onSubmit(onSearch)
    }
}

#Preview("MomensSearchInput - Default and Active") {
    VStack(spacing: 16) {
        MomensSearchInput(text: .constant(""), placeholder: "Search", onSearch: {})
        MomensSearchInput(text: .constant("Search"), onSearch: {})
    }
    .frame(width: 343)
    .padding(16)
}
