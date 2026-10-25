import SwiftUI

struct MainTabView: View {
    @State private var coordinator = MainTabCoordinator()
    let container: DIContainer

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            SignalNavigationStack(container: container)
                .tabItem {
                    Label(MainTab.signal.title, systemImage: MainTab.signal.systemImage)
                }
                .tag(MainTab.signal)

            BriefNavigationStack(container: container)
                .tabItem {
                    Label(MainTab.brief.title, systemImage: MainTab.brief.systemImage)
                }
                .tag(MainTab.brief)

            ProjectNavigationStack(container: container)
                .tabItem {
                    Label(MainTab.project.title, systemImage: MainTab.project.systemImage)
                }
                .tag(MainTab.project)
        }
        .environment(coordinator)
    }
}
