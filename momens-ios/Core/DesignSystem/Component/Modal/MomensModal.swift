import SwiftUI

struct MomensModal: View {
    let title: String
    let message: String
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Image("ic_warning_modal")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(4)

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
                Button(action: onCancel) {
                    Text("취소하기")
                        .foregroundStyle(MomensColor.white)
                        .momensFont(.bodyB16)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(MomensColor.gray300, in: .rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button(action: onConfirm) {
                    Text("삭제하기")
                        .foregroundStyle(MomensColor.white)
                        .momensFont(.bodyB16)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(MomensColor.primary100, in: .rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
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
