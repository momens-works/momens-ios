import SwiftUI

struct MomensImportantStatus: View {
    let level: MomensImportantStatusLevel
    var color: MomensImportantStatusColorStyle = .gray

    private var iconName: String {
        "ic_importance_\(level.rawValue)_\(color.iconColor)"
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)

            Text(level.title)
                .foregroundStyle(color.foregroundColor)
                .momensFont(color.typography)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 10)
        .background(color.backgroundColor)
        .clipShape(.rect(cornerRadius: 4))
    }
}

#Preview("MomensImportantStatus - Variants") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(MomensImportantStatusColorStyle.allCases, id: \.self) { color in
            HStack(spacing: 8) {
                ForEach(MomensImportantStatusLevel.allCases, id: \.self) { level in
                    MomensImportantStatus(level: level, color: color)
                }
            }
        }
    }
    .padding(16)
    .background(MomensColor.gray100)
}
