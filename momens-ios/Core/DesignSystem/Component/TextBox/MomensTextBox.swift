import SwiftUI

struct MomensTextBox: View {
    let text: String
    var color: MomensTextBoxColorStyle = .gray
    var size: MomensTextBoxSizeStyle = .default
    var isArrow = false
    var onTap: (() -> Void)?

    private var textColor: Color {
        switch (color, size) {
        case (.blue, .default), (.blue, .large):
            MomensColor.primary100
        default:
            MomensColor.gray500
        }
    }

    private var trailingPadding: CGFloat {
        size == .large ? 24 : 12
    }

    var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) {
                    content
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    private var content: some View {
        HStack(spacing: 4) {
            Image(decorative: "ic_minsu")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(MomensColor.primary100)

            Text(text)
                .foregroundStyle(textColor)
                .momensFont(.captionM11)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if isArrow {
                Image(decorative: "ic_arrow")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(MomensColor.gray500)
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, 12)
        .padding(.trailing, trailingPadding)
        .background(MomensColor.primary10)
        .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview("MomensTextBox - Variants") {
    VStack(alignment: .leading, spacing: 10) {
        MomensTextBox(text: "Text")
            .frame(width: 311)

        MomensTextBox(text: "Text", color: .blue)
            .frame(width: 311)

        MomensTextBox(text: "Text", size: .large)
            .frame(width: 343)

        MomensTextBox(text: "Text", color: .blue, size: .large)
            .frame(width: 343)

        MomensTextBox(text: "Text", color: .blue, size: .medium, isArrow: true, onTap: {})
            .frame(width: 335)
    }
    .padding(16)
    .frame(width: 375, alignment: .leading)
    .background(MomensColor.gray100)
}
