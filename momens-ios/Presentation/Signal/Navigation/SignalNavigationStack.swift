import SwiftUI

struct SignalNavigationStack: View {
    @Environment(MainTabCoordinator.self) private var coordinator
    let container: DIContainer

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.signalPath) {
            NavigationPlaceholderView(title: "시그널")
                .navigationDestination(for: SignalRoute.self) { route in
                    switch route {
                    case .detail:
                        NavigationPlaceholderView(title: "시그널 상세")
                    }
                }
        }
    }
}
