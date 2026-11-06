import SwiftUI

struct MomensSectionTitle: View {
    enum Style {
        case thin
        case bold
    }

    let text: String
    let style: Style
    let detail: String?
    private let iconAssetName: String?

    init(
        _ text: String,
        style: Style = .thin,
        detail: String? = nil
    ) {
        self.text = text
        self.style = style
        self.detail = detail
        iconAssetName = nil
    }

    init(
        _ text: String,
        detail: String? = nil,
        iconAssetName: String
    ) {
        self.text = text
        style = .bold
        self.detail = detail
        self.iconAssetName = iconAssetName
    }

    private var typography: MomensTypography {
        switch style {
        case .thin:
            .bodyM14
        case .bold:
            .bodyB14
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .thin:
            MomensColor.gray700
        case .bold:
            MomensColor.gray900
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            if let iconAssetName {
                Image(decorative: iconAssetName, bundle: nil)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(MomensColor.primary100)
                    .frame(width: 24, height: 24)
            }

            Text(text)
                .momensFont(typography)
                .foregroundStyle(foregroundColor)

            if let detail {
                Circle()
                    .fill(foregroundColor)
                    .frame(width: 2, height: 2)

                Text(detail)
                    .momensFont(typography)
                    .foregroundStyle(foregroundColor)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Section Title Variants") {
    VStack(alignment: .leading, spacing: 20) {
        MomensSectionTitle("제목", style: .thin, detail: "4")
        MomensSectionTitle("제목", style: .bold, detail: "4")
        MomensSectionTitle(
            "제목",
            detail: "4",
            iconAssetName: "ic_canceled"
        )
    }
    .padding(20)
}
