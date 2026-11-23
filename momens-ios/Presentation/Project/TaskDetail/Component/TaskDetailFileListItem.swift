import SwiftUI

struct TaskDetailFileListItem: View {
    let title: String
    let role: String
    let category: String
    let type: MomensSourceType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                HStack(spacing: 16) {
                    Image(decorative: type.iconAssetName, bundle: nil)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(MomensColor.primary50)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 7)
                        .background(MomensColor.white, in: RoundedRectangle(cornerRadius: 4))

                    textContent
                        .layoutPriority(1)
                }

                Spacer(minLength: 0)

                Image(decorative: "ic_next", bundle: nil)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(MomensColor.black)
                    .frame(width: 24, height: 24)
            }
            .padding(11)
            .background(MomensColor.gray100, in: RoundedRectangle(cornerRadius: 8))
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .momensFont(.bodyB12)
                .foregroundStyle(MomensColor.black)

            HStack(spacing: 6) {
                Text(role)

                MomensDot(color: MomensColor.gray400)
                    .accessibilityHidden(true)

                Text(category)
            }
            .momensFont(.captionM11)
            .foregroundStyle(MomensColor.gray400)
        }
    }
}

#Preview("File List Item - Default") {
    TaskDetailFileListItem(
        title: "회원가입 에러 메시지 정책 초안",
        role: "PM",
        category: "copy policy",
        type: .file,
        onTap: {}
    )
    .frame(width: 343)
    .padding(16)
}

#Preview("File List Item - Long Text and Custom Icon") {
    TaskDetailFileListItem(
        title: "회원가입 에러 메시지 정책 초안과 온보딩 화면 디자인 검토 자료",
        role: "Product Designer",
        category: "2026.07.15 22:48",
        type: .figma,
        onTap: {}
    )
    .frame(width: 280)
    .padding(16)
}
