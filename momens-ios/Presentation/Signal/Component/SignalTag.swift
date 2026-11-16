import SwiftUI

struct SignalTag: View {
    let type: SignalTagType

    private var backgroundColor: Color {
        switch type {
        case .risk:
            MomensColor.pointRed
        case .decision:
            MomensColor.pointPurple
        case .change:
            MomensColor.pointYellow
        case .question:
            MomensColor.pointMint
        }
    }

    var body: some View {
        Text(type.label)
            .momensFont(.captionB11)
            .foregroundStyle(MomensColor.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 1)
            .background(backgroundColor, in: .rect(cornerRadius: 4))
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
