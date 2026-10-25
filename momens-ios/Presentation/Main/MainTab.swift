import Foundation

enum MainTab: Hashable, CaseIterable {
    case signal
    case brief
    case project

    var title: String {
        switch self {
        case .signal:
            "시그널"
        case .brief:
            "브리프"
        case .project:
            "태스크"
        }
    }

    var systemImage: String {
        switch self {
        case .signal:
            "dot.radiowaves.left.and.right"
        case .brief:
            "doc.text"
        case .project:
            "checklist"
        }
    }
}
