import SwiftUI

struct ProjectNavigationStack: View {
    @Environment(MainTabCoordinator.self) private var coordinator
    let container: DIContainer

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.projectPath) {
            NavigationPlaceholderView(title: "태스크")
                .navigationDestination(for: ProjectRoute.self) { route in
                    switch route {
                    case .task:
                        NavigationPlaceholderView(title: "프로젝트 태스크")

                    case .taskDetail:
                        NavigationPlaceholderView(title: "태스크 상세")

                    case .taskEdit:
                        NavigationPlaceholderView(title: "태스크 편집")
                    }
                }
        }
    }
}
