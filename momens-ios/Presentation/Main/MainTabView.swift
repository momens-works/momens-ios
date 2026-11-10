import SwiftUI

struct MainTabView: View {
    @State private var coordinator = MainTabCoordinator()
    let container: DIContainer
    let usesSystemTabBar: Bool
    @State private var tabBarHeight: CGFloat = 0

    private let tabBarBottomSpacing: CGFloat = -13

    init(container: DIContainer, usesSystemTabBar: Bool = Self.supportsLiquidGlass) {
        self.container = container
        self.usesSystemTabBar = usesSystemTabBar
        Self.setupTabBarStyle()
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.selectedTab) {
            SignalNavigationStack(container: container)
                .tabItem { tabLabel(.signal) }
                .tag(MainTab.signal)
                .modifier(HideSystemTabBar(isHidden: !usesSystemTabBar, bottomInset: tabBarInset))

            BriefNavigationStack(container: container)
                .tabItem { tabLabel(.brief) }
                .tag(MainTab.brief)
                .modifier(HideSystemTabBar(isHidden: !usesSystemTabBar, bottomInset: tabBarInset))

            ProjectNavigationStack(container: container)
                .tabItem { tabLabel(.project) }
                .tag(MainTab.project)
                .modifier(HideSystemTabBar(isHidden: !usesSystemTabBar, bottomInset: tabBarInset))
        }
        .tint(MomensColor.primary100)
        .overlay(alignment: .bottom) {
            if !usesSystemTabBar {
                MomensMainTabBar(
                    selectedTab: coordinator.selectedTab,
                    onTabClick: { coordinator.selectedTab = $0 }
                )
                .onGeometryChange(
                    for: CGFloat.self,
                    of: { $0.size.height },
                    action: { tabBarHeight = $0 }
                )
                .padding(.bottom, tabBarBottomSpacing)
            }
        }
        .environment(coordinator)
    }

    private var tabBarInset: CGFloat {
        usesSystemTabBar ? 0 : tabBarHeight + tabBarBottomSpacing
    }

    private static var supportsLiquidGlass: Bool {
        if #available(iOS 26, *) {
            true
        } else {
            false
        }
    }

    private func tabLabel(_ tab: MainTab) -> some View {
        Label(tab.title, image: tab.iconName)
    }

    private static func setupTabBarStyle() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SUIT-Medium", size: 11) as Any,
            .foregroundColor: UIColor(MomensColor.gray300)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SUIT-Bold", size: 11) as Any,
            .foregroundColor: UIColor(MomensColor.primary100)
        ]

        let appearance = UITabBarAppearance()
        let layouts = [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ]
        for layout in layouts {
            layout.normal.iconColor = UIColor(MomensColor.gray300)
            layout.normal.titleTextAttributes = normalAttributes
            layout.selected.iconColor = UIColor(MomensColor.primary100)
            layout.selected.titleTextAttributes = selectedAttributes
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().unselectedItemTintColor = UIColor(MomensColor.gray300)
    }
}

private struct HideSystemTabBar: ViewModifier {
    let isHidden: Bool
    let bottomInset: CGFloat

    func body(content: Content) -> some View {
        if isHidden {
            content
                .toolbar(.hidden, for: .tabBar)
                .contentMargins(.bottom, bottomInset, for: .scrollContent)
        } else {
            content
        }
    }
}

#Preview("MainTabView - Liquid Glass (iOS 26+)") {
    MainTabView(container: DIContainer(), usesSystemTabBar: true)
}

#Preview("MainTabView - Custom Bar (iOS 26 미만)") {
    MainTabView(container: DIContainer(), usesSystemTabBar: false)
}
