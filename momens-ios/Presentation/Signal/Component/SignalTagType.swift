import SwiftUI

enum SignalTagType: String, CaseIterable, Hashable {
    case risk
    case decision
    case change
    case question

    var label: String {
        switch self {
        case .risk:
            "Risk"
        case .decision:
            "Decision"
        case .change:
            "Change"
        case .question:
            "Question"
        }
    }

    var backgroundColor: Color {
        switch self {
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
}
