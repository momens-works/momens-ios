import SwiftUI

struct SignalTag: View {
    let type: SignalTagType

    var body: some View {
        Text(type.label)
            .momensFont(.captionB11)
            .foregroundStyle(MomensColor.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 1)
            .background(type.backgroundColor, in: .rect(cornerRadius: 4))
    }
}

#Preview("Signal Tag Types") {
    HStack(spacing: 8) {
        ForEach(SignalTagType.allCases, id: \.self) { type in
            SignalTag(type: type)
        }
    }
    .padding(16)
}
