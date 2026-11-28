import SwiftUI

struct MomensModal: View {
    let title: String
    let message: String
    var cancelText = "취소하기"
    var confirmText = "삭제하기"
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Image(.icWarning)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)

                VStack(spacing: 4) {
                    Text(title)
                        .foregroundStyle(MomensColor.black)
                        .momensFont(.bodyB16)

                    Text(message)
                        .foregroundStyle(MomensColor.gray500)
                        .momensFont(.bodyM14)
                }
                .multilineTextAlignment(.center)
            }

            HStack(spacing: 8) {
                MomensCtaButton(action: onCancel, type: .cancel) {
                    Text(cancelText)
                        .foregroundStyle(MomensColor.gray700)
                        .momensFont(.bodyB16)
                }

                MomensCtaButton(action: onConfirm) {
                    Text(confirmText)
                        .foregroundStyle(MomensColor.white)
                        .momensFont(.bodyB16)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(MomensColor.white, in: .rect(cornerRadius: 20))
    }
}

#Preview("Task Delete Confirmation Modal") {
    MomensModal(
        title: "태스크를 삭제하시겠습니까?",
        message: "삭제하면 복구할 수 없습니다",
        onCancel: {},
        onConfirm: {}
    )
        .frame(width: 343)
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomensColor.uiBlackBackground)
}

#Preview("Modal - Custom Button Labels") {
    MomensModal(
        title: "로그아웃하시겠습니까?",
        message: "다시 로그인하여 이용할 수 있습니다",
        cancelText: "닫기",
        confirmText: "로그아웃",
        onCancel: {},
        onConfirm: {}
    )
        .frame(width: 343)
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomensColor.uiBlackBackground)
}
