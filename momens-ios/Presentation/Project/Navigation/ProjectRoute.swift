import Foundation

enum ProjectRoute: Hashable {
    case task(projectId: Int)
    case taskDetail(taskId: String)
    case taskEdit(taskId: String)
}
