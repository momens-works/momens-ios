import SwiftUI

struct MomensImportantStatus: View {
    let level: MomensImportantStatusLevel
    var style: MomensImportantStatusStyle = .unselected

    private var iconName: String {
        "ic_importance_\(level.iconAssetLevel)_\(style.iconColor)"
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)

            Text(level.title)
                .foregroundStyle(style.foregroundColor)
                .momensFont(style.typography)
        }
        .padding(.vertical, style.isBadge ? 2 : 0)
        .padding(.horizontal, style.isBadge ? 10 : 0)
        .background(style.backgroundColor)
        .clipShape(.rect(cornerRadius: 4))
    }
}

#Preview("MomensImportantStatus - Variants") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(MomensImportantStatusStyle.allCases, id: \.self) { style in
            HStack(spacing: 8) {
                ForEach(MomensImportantStatusLevel.allCases, id: \.self) { level in
                    MomensImportantStatus(level: level, style: style)
                }
            }
            .padding(style == .taskList ? 8 : 0)
            .background(style == .taskList ? MomensColor.white : Color.clear)
        }
    }
    .padding(16)
    .background(MomensColor.gray100)
}

#Preview("MomensImportantStatus - White Badge") {
    HStack(spacing: 8) {
        ForEach(MomensImportantStatusLevel.allCases, id: \.self) { level in
            MomensImportantStatus(level: level, style: .whiteBadge)
        }
    }
    .padding(16)
    .background(MomensColor.gray100)
}
