import Observation

@Observable
final class MainTabCoordinator {
    var selectedTab: MainTab = .signal
    var signalPath: [SignalRoute] = []
    var briefPath: [BriefRoute] = []
    var projectPath: [ProjectRoute] = []

    func showProject(projectId: Int) {
        selectedTab = .project
        projectPath = [.task(projectId: projectId)]
    }
}
