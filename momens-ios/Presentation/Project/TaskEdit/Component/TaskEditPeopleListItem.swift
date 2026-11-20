import Kingfisher
import SwiftUI

struct TaskEditPeopleListItem: View {
    let text: String
    let onDeleteClick: () -> Void
    var isSelected = false
    var showsProfile = true
    var profileImageUrl: String?
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

            if isSelected {
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
        TaskEditPeopleListItem(text: "강채원", onDeleteClick: {})
        TaskEditPeopleListItem(text: "강채원", onDeleteClick: {}, isSelected: true)
        TaskEditPeopleListItem(text: "강채원", onDeleteClick: {}, showsProfile: false)
        TaskEditPeopleListItem(text: "강채원", onDeleteClick: {}, isSelected: true, showsProfile: false)
    }
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("PeopleList - Selection and Deletion") {
    @Previewable @State var isSelected = false
    @Previewable @State var selectionCount = 0
    @Previewable @State var deletionCount = 0

    VStack(spacing: 16) {
        TaskEditPeopleListItem(
            text: "강채원",
            onDeleteClick: {
                deletionCount += 1
                isSelected = false
            },
            isSelected: isSelected,
            onClick: {
                selectionCount += 1
                isSelected = true
            }
        )

        Text("선택 \(selectionCount)회 · 삭제 \(deletionCount)회")
            .momensFont(.bodyM12)
    }
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("PeopleList - Long Name") {
    TaskEditPeopleListItem(
        text: "긴 이름을 가진 프로젝트 참여자 강채원입니다",
        onDeleteClick: {},
        isSelected: true
    )
    .frame(width: 240)
    .padding(16)
    .background(MomensColor.gray100)
}
