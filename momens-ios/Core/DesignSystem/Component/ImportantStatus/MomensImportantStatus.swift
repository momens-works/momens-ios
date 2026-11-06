import SwiftUI

struct MomensImportantStatus: View {
    enum Level: String, CaseIterable, Hashable {
        case low
        case medium
        case high

        var title: String {
            switch self {
            case .low:
                "낮음"
            case .medium:
                "중간"
            case .high:
                "높음"
            }
        }
    }

    enum ColorStyle: CaseIterable, Hashable {
        case gray
        case white
        case blue
    }

    let level: Level
    var color: ColorStyle = .gray

    private var backgroundColor: Color {
        switch color {
        case .gray:
            MomensColor.gray100
        case .white:
            MomensColor.white
        case .blue:
            MomensColor.primary50
        }
    }

    private var foregroundColor: Color {
        color == .blue ? MomensColor.primary10 : MomensColor.gray700
    }

    private var typography: MomensTypography {
        color == .blue ? .bodyB12 : .bodyM12
    }

    private var iconName: String {
        let iconColor = color == .blue ? "blue" : "gray"
        return "ic_importance_\(level.rawValue)_\(iconColor)"
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(iconName)
                .resizable()
                .frame(width: 24, height: 24)

            Text(level.title)
                .foregroundStyle(foregroundColor)
                .momensFont(typography)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 10)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 4))
    }
}

#Preview("MomensImportantStatus - Variants") {
    VStack(alignment: .leading, spacing: 12) {
        ForEach(MomensImportantStatus.ColorStyle.allCases, id: \.self) { color in
            HStack(spacing: 8) {
                ForEach(MomensImportantStatus.Level.allCases, id: \.self) { level in
                    MomensImportantStatus(level: level, color: color)
                }
            }
        }
    }
    .padding(16)
    .background(MomensColor.gray100)
}
