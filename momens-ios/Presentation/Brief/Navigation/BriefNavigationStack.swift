import SwiftUI

struct BriefNavigationStack: View {
    @Environment(MainTabCoordinator.self) private var coordinator
    let container: DIContainer

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.briefPath) {
            NavigationPlaceholderView(title: "브리프")
                .navigationDestination(for: BriefRoute.self) { route in
                    switch route {
                    case .detail:
                        NavigationPlaceholderView(title: "브리프 상세")
                    }
                }
        }
    }
}
