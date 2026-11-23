import SwiftUI

struct MomensTaskTag: View {
    let type: MomensTaskStatusType

    var body: some View {
        HStack(spacing: 2) {
            Image(type.iconAsset)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 16, height: 16)
                .accessibilityHidden(true)

            Text(type.label)
                .momensFont(.captionB11)
        }
        .foregroundStyle(MomensColor.primary100)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(MomensColor.primary10, in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(MomensColor.primary50, lineWidth: 1)
        }
    }
}

#Preview("Task Tag Statuses") {
    VStack(alignment: .leading, spacing: 20) {
        ForEach(MomensTaskStatusType.allCases, id: \.self) { type in
            MomensTaskTag(type: type)
        }
    }
    .padding(20)
}
