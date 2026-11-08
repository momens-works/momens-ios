import SwiftUI

enum MomensImportantStatusLevel: String, CaseIterable, Hashable {
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
