import SwiftUI

struct MomensSectionTitle: View {
    let text: String
    let style: MomensSectionTitleStyle
    let detail: String?
    private let iconAssetName: String?

    init(
        _ text: String,
        style: MomensSectionTitleStyle = .thin,
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
                MomensDot(color: foregroundColor)

                Text(detail)
                    .momensFont(typography)
                    .foregroundStyle(foregroundColor)
            }
        }
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

#Preview("Section Title - Long Text") {
    MomensSectionTitle(
        "길이가 긴 제목이 좁은 화면에 표시되는 경우를 확인합니다",
        detail: "긴 상세 텍스트"
    )
    .frame(width: 180)
    .padding(20)
}
