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

    var iconName: String {
        switch self {
        case .todo:
            "ic_todo"
        case .inProgress:
            "ic_inprogress"
        case .done:
            "ic_done"
        case .canceled:
            "ic_canceled"
        case .backlog:
            "ic_backlog"
        }
    }
}
