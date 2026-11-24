import SwiftUI

struct MomensChipButton: View {
    let label: String
    let action: () -> Void
    var count: Int?
    var type: MomensChipButtonType = .white

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)

                if let count, count > 0 {
                    Text("\(count)")
                }
            }
            .momensFont(.captionM10)
            .foregroundStyle(type.textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(type.backgroundColor, in: .capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview("MomensChipButton - Variants") {
    VStack(alignment: .leading, spacing: 10) {
        MomensChipButton(label: "All", action: {}, count: 0, type: .white)
        MomensChipButton(label: "All", action: {}, count: 2, type: .black)
        MomensChipButton(label: "Decision", action: {}, count: 2, type: .purple)
        MomensChipButton(label: "Risk", action: {}, count: 2, type: .red)
        MomensChipButton(label: "Change", action: {}, count: 2, type: .yellow)
        MomensChipButton(label: "Question", action: {}, count: 2, type: .mint)
    }
    .padding(16)
    .background(MomensColor.gray500)
}
