import DeveloperToolsSupport

enum MomensTaskStatusType: String, CaseIterable {
    case todo
    case inProgress = "in_progress"
    case done
    case canceled = "cancelled"
    case backlog

    var label: String {
        switch self {
        case .todo:
            "투두"
        case .inProgress:
            "진행중"
        case .done:
            "완료"
        case .canceled:
            "취소"
        case .backlog:
            "백로그"
        }
    }

    var iconAsset: ImageResource {
        switch self {
        case .todo:
            .icTodo
        case .inProgress:
            .icInprogress
        case .done:
            .icDone
        case .canceled:
            .icCanceled
        case .backlog:
            .icBacklog
        }
    }
}
