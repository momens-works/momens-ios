import SwiftUI

struct TaskEditStatusEdit: View {
    let type: MomensStatusEditType
    var isSelected = false
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 4) {
                Image(type.iconAsset)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(MomensColor.primary100)
                    .accessibilityHidden(true)

                Text(type.label)
                    .momensFont(.captionM11)
                    .foregroundStyle(isSelected ? MomensColor.primary100 : MomensColor.gray500)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? MomensColor.primary10 : MomensColor.white,
                in: .rect(cornerRadius: 8)
            )
            .contentShape(.rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Status Edit - Figma States") {
    VStack(spacing: 20) {
        TaskEditStatusEdit(type: .backlog, isSelected: true, onClick: {})
        TaskEditStatusEdit(type: .backlog, onClick: {})
    }
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("Status Edit - Select a Status") {
    @Previewable @State var selected: MomensStatusEditType = .backlog

    VStack(spacing: 8) {
        ForEach(MomensStatusEditType.allCases, id: \.self) { type in
            TaskEditStatusEdit(type: type, isSelected: selected == type) {
                selected = type
            }
        }
    }
    .frame(width: 343)
    .padding(16)
    .background(MomensColor.gray100)
}
