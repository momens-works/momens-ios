import DeveloperToolsSupport

enum MomensStatusEditType: String, CaseIterable, Hashable {
    case backlog
    case todo
    case inProgress = "in_progress"
    case done
    case canceled = "canceled"

    var label: String {
        switch self {
        case .backlog: "백로그"
        case .todo: "투두"
        case .inProgress: "진행중"
        case .done: "완료"
        case .canceled: "취소"
        }
    }

    var iconAsset: ImageResource {
        switch self {
        case .backlog: .icBacklog
        case .todo: .icTodo
        case .inProgress: .icInprogress
        case .done: .icDone
        case .canceled: .icCanceled
        }
    }
}
