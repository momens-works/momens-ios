import Kingfisher
import SwiftUI

struct MomensDefaultHeader: View {
    let onProfileClick: () -> Void
    var backgroundColor: Color = .clear
    var avatarUrl: String?

    private var avatar: URL? {
        avatarUrl.flatMap { URL(string: $0) }
    }

    var body: some View {
        HStack {
            Image("ic_momens_logo")

            Spacer()

            Button(action: onProfileClick) {
                KFImage(avatar)
                    .placeholder {
                        Image("ic_person")
                            .renderingMode(.template)
                            .foregroundStyle(MomensColor.white)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .background(MomensColor.primary50, in: .circle)
                    .clipShape(.circle)
                    .frame(minWidth: 44, minHeight: 44, alignment: .trailing)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
}

#Preview("MomensDefaultHeader") {
    MomensDefaultHeader(onProfileClick: {}, backgroundColor: MomensColor.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(MomensColor.gray100)
}
