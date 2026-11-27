import SwiftUI

enum BriefSignalSummaryFilterType {
    case all
    case change
    case decision
    case question
    case risk

    var signalColor: Color {
        switch self {
        case .change:
            MomensColor.pointYellow
        case .decision:
            MomensColor.pointPurple
        case .question:
            MomensColor.pointMint
        case .risk:
            MomensColor.pointRed
        case .all:
            MomensColor.gray400
        }
    }
}
