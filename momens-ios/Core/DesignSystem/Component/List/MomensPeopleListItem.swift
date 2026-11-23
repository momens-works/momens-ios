import Kingfisher
import SwiftUI

struct MomensPeopleListItem: View {
    let text: String
    var profileImageUrl: String?

    var isSelected = false
    var showsProfile = true

    var onDeleteClick: (() -> Void)?
    var onClick: () -> Void = {}

    private var profileURL: URL? {
        guard let value = profileImageUrl?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else { return nil }
        return URL(string: value)
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: onClick) {
                HStack(spacing: 10) {
                    if showsProfile {
                        profileIcon
                            .accessibilityHidden(true)
                    }

                    Text(text)
                        .momensFont(.bodyB14)
                        .foregroundStyle(MomensColor.black)
                        .lineLimit(1)

                    Spacer(minLength: 0)
                }
                .frame(minHeight: 34)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(text)
            .accessibilityAddTraits(isSelected ? .isSelected : [])

            if isSelected, let onDeleteClick {
                MomensButton(text: "삭제", action: onDeleteClick, type: .white)
                    .fixedSize()
                    .accessibilityLabel("\(text) 삭제")
                    .padding(.trailing, 10)
            }
        }
        .background(
            isSelected ? MomensColor.primary10 : MomensColor.white,
            in: .rect(cornerRadius: 8)
        )
    }

    private var profileIcon: some View {
        Group {
            if let profileURL {
                KFImage(profileURL)
                    .placeholder { defaultProfileIcon }
                    .resizable()
                    .scaledToFill()
            } else {
                defaultProfileIcon
            }
        }
        .frame(width: 34, height: 34)
        .background(isSelected ? MomensColor.white : MomensColor.primary10, in: .circle)
        .clipShape(.circle)
    }

    private var defaultProfileIcon: some View {
        Image(.icPerson)
            .renderingMode(.template)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(MomensColor.primary50)
            .frame(width: 34, height: 34)
    }
}

#Preview("PeopleList - Figma States") {
    VStack(spacing: 16) {
        MomensPeopleListItem(text: "강채원")
        MomensPeopleListItem(text: "강채원", isSelected: true, onDeleteClick: {})
        MomensPeopleListItem(text: "강채원", showsProfile: false)
        MomensPeopleListItem(text: "강채원", isSelected: true, showsProfile: false, onDeleteClick: {})
    }
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("PeopleList - Unselected") {
    @Previewable @State var isSelected = false

    MomensPeopleListItem(
        text: "강채원",
        isSelected: isSelected,
        onDeleteClick: { isSelected = false },
        onClick: { isSelected.toggle() }
    )
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("PeopleList - Selected") {
    @Previewable @State var isSelected = true

    MomensPeopleListItem(
        text: "강채원",
        isSelected: isSelected,
        onDeleteClick: { isSelected = false },
        onClick: { isSelected.toggle() }
    )
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}
