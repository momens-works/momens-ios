import SwiftUI

struct MomensHeader: View {
    let text: String
    let onBackClick: () -> Void
    var backgroundColor: Color = MomensColor.white
    var isSaveVisible = false
    var isWriteVisible = false
    var onWriteClick: () -> Void = {}
    var onSaveClick: () -> Void = {}

    private let sideWidth: CGFloat = 40

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onBackClick) {
                Image("ic_next")
                    .renderingMode(.template)
                    .foregroundStyle(MomensColor.gray500)
                    .scaleEffect(x: -1, y: 1)
            }
            .buttonStyle(.plain)
            .frame(minWidth: sideWidth, alignment: .leading)

            Text(text)
                .foregroundStyle(MomensColor.black)
                .momensFont(.bodyM16)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            HStack(spacing: 8) {
                if isWriteVisible {
                    Button(action: onWriteClick) {
                        Image("ic_write")
                            .renderingMode(.template)
                            .foregroundStyle(MomensColor.gray500)
                    }
                    .buttonStyle(.plain)
                }

                if isSaveVisible {
                    Button(action: onSaveClick) {
                        Text("완료")
                            .foregroundStyle(MomensColor.gray900)
                            .momensFont(.bodyB14)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(minWidth: sideWidth, alignment: .trailing)
        }
        .padding(.horizontal, 19)
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
            isWriteVisible: true
        )

        MomensHeader(
            text: "우우와와우와우와와 타쿠타쿠 챠오 우우와와우와우와와",
            onBackClick: {},
            isSaveVisible: true
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(MomensColor.gray100)
}
