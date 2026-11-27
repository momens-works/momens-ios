import SwiftUI

struct SignalAccordionHeader: View {
    let type: MomensSourceType
    let time: String
    let expanded: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 0) {
                Image(decorative: type.iconAssetName, bundle: nil)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(type.text)
                    .momensFont(.bodyB14)
                    .foregroundStyle(MomensColor.gray900)
                    .padding(.leading, 4)

                Spacer(minLength: 12)

                Text(time)
                    .momensFont(.bodyB12)
                    .foregroundStyle(MomensColor.gray500)

                Image(decorative: "ic_next", bundle: nil)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .rotationEffect(.degrees(expanded ? -90 : 90))
                    .foregroundStyle(MomensColor.black)
                    .padding(.leading, 12)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                MomensColor.gray200,
                in: UnevenRoundedRectangle(
                    topLeadingRadius: 8,
                    bottomLeadingRadius: expanded ? 0 : 8,
                    bottomTrailingRadius: expanded ? 0 : 8,
                    topTrailingRadius: 8
                )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(AccordionHeaderButtonStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(type.text), \(time)")
        .accessibilityValue(expanded ? "펼쳐짐" : "접힘")
    }
}

private struct AccordionHeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
