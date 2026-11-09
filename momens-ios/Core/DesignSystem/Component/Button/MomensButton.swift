import SwiftUI

struct MomensButton: View {
    let text: String
    let action: () -> Void
    var isSelected = false
    var type: MomensButtonType?
    var isDropdown = false

    private var resolvedType: MomensButtonType {
        type ?? (isSelected ? .primary : .gray)
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Text(text)
                    .momensFont(resolvedType.typography(isDropdown: isDropdown))

                if isDropdown {
                    Image("ic_down")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
            .foregroundStyle(resolvedType.textColor(isDropdown: isDropdown))
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
        MomensButton(text: "버튼", action: {}, type: .white, isDropdown: true)
        MomensButton(text: "버튼", action: {}, type: .primary, isDropdown: true)
    }
    .padding(16)
    .background(MomensColor.pointRed)
}
