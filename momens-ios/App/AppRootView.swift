import SwiftUI

struct AppRootView: View {
    @Environment(AppCoordinator.self) private var appCoordinator
    let container: DIContainer

    var body: some View {
        // Splash flow will be connected with its feature implementation.
        MainTabView(container: container)
    }
}
