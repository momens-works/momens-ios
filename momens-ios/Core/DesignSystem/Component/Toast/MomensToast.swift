import SwiftUI

struct MomensToast: View {
    let type: MomensToastType
    let title: String

    private var iconName: String {
        switch type {
        case .default:
            "ic_warning"
        case .button:
            "ic_checkbox_fill"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            toastIcon

            switch type {
            case .default:
                Text(title)
                    .momensFont(.bodyB14)
                    .foregroundStyle(MomensColor.white)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

            case let .button(actionTitle, subtitle, onTap):
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .momensFont(.bodyB14)
                        .foregroundStyle(MomensColor.white)
                        .fixedSize(horizontal: false, vertical: true)

                    if let subtitle {
                        Text(subtitle)
                            .momensFont(.captionM11)
                            .foregroundStyle(MomensColor.gray300)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 12)

                MomensButton(text: actionTitle, action: onTap, type: .primary)
                    .frame(minWidth: 44, minHeight: 44)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(MomensColor.gray700, in: .rect(cornerRadius: 8))
    }

    @ViewBuilder
    private var toastIcon: some View {
        switch type {
        case .default:
            Image(decorative: iconName)
                .frame(width: 16, height: 16)
                .frame(width: 24, height: 24)

        case .button:
            Image(decorative: iconName)
                .renderingMode(.template)
                .foregroundStyle(MomensColor.gray400)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview("MomensToast Variants") {
    VStack(spacing: 18) {
        MomensToast(
            type: .button(
                actionTitle: "바로보기",
                subtitle: "text",
                onTap: {}
            ),
            title: "text"
        )
        .frame(maxWidth: .infinity)

        MomensToast(type: .default, title: "text")
            .frame(maxWidth: .infinity)
    }
    .padding(16)
}
