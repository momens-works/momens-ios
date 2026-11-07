import SwiftUI

struct MomensButton: View {
    let text: String
    let action: () -> Void
    var isSelected = false
    var type: MomensButtonType?

    private var resolvedType: MomensButtonType {
        type ?? (isSelected ? .primary : .gray)
    }

    var body: some View {
        Button(action: action) {
            Text(text)
                .foregroundStyle(resolvedType.textColor)
                .momensFont(resolvedType.typography)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(resolvedType.backgroundColor, in: .rect(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
}

#Preview("MomensButton - Variants") {
    VStack(spacing: 16) {
        MomensButton(text: "버튼", action: {})
        MomensButton(text: "선택", action: {}, isSelected: true)
        MomensButton(text: "버튼", action: {}, type: .gray)
        MomensButton(text: "버튼", action: {}, type: .primary)
        MomensButton(text: "버튼", action: {}, type: .black)
        MomensButton(text: "버튼", action: {}, type: .white)
    }
    .padding(16)
    .background(MomensColor.pointRed)
}
