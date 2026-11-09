import SwiftUI

struct MomensHeader: View {
    let text: String
    let onBackClick: () -> Void
    var backgroundColor: Color = MomensColor.white
    var trailingAction: MomensHeaderTrailingAction?
    var onTrailingClick: () -> Void = {}

    private let sideWidth: CGFloat = 44

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBackClick) {
                Image("ic_next")
                    .renderingMode(.template)
                    .foregroundStyle(MomensColor.gray500)
                    .scaleEffect(x: -1, y: 1)
            }
            .buttonStyle(.plain)
            .frame(minWidth: sideWidth, minHeight: sideWidth, alignment: .leading)
            .contentShape(.rect)

            Text(text)
                .foregroundStyle(MomensColor.black)
                .momensFont(.bodyM16)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Group {
                if let trailingAction {
                    Button(action: onTrailingClick) {
                        switch trailingAction {
                        case .write:
                            Image("ic_write")
                                .renderingMode(.template)
                                .foregroundStyle(MomensColor.gray500)
                        case .save:
                            Text("완료")
                                .foregroundStyle(MomensColor.gray900)
                                .momensFont(.bodyB14)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minWidth: sideWidth, minHeight: sideWidth, alignment: .trailing)
            .contentShape(.rect)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

#Preview("MomensHeader - Variants") {
    VStack(spacing: 0) {
        MomensHeader(text: "파자마 파티즈", onBackClick: {})

        MomensHeader(
            text: "우우와와우와우와와 타쿠타쿠 챠오 우우와와우와우와와",
            onBackClick: {},
            trailingAction: .write
        )

        MomensHeader(
            text: "우우와와우와우와와 타쿠타쿠 챠오 우우와와우와우와와",
            onBackClick: {},
            trailingAction: .save
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(MomensColor.gray100)
}
