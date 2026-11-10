import SwiftUI

struct MomensMainTabBar: View {
    var tabs: [MainTab] = MainTab.allCases
    let selectedTab: MainTab
    let onTabClick: (MainTab) -> Void

    @Namespace private var selectionNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs, id: \.self) { tab in
                MomensMainTabBarItem(
                    tab: tab,
                    isSelected: tab == selectedTab,
                    namespace: selectionNamespace,
                    onClick: { withAnimation(.snappy) { onTabClick(tab) } }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .modifier(MomensNavBarBackground())
    }
}

private struct MomensMainTabBarItem: View {
    let tab: MainTab
    let isSelected: Bool
    let namespace: Namespace.ID
    let onClick: () -> Void

    private var contentColor: Color {
        isSelected ? MomensColor.primary100 : MomensColor.gray300
    }

    private var typography: MomensTypography {
        isSelected ? .captionB11 : .captionM11
    }

    var body: some View {
        Button(action: onClick) {
            VStack(spacing: 0) {
                Image(tab.iconName)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(tab.title)
                    .momensFont(typography)
            }
            .foregroundStyle(contentColor)
            .padding(.horizontal, 20)
            .padding(.vertical, isSelected ? 4 : 2)
            .background {
                if isSelected {
                    Capsule()
                        .fill(MomensColor.white)
                        .matchedGeometryEffect(id: "selection", in: namespace)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct MomensNavBarBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(MomensColor.navigationGray, in: .capsule)
            .background(MomensBackdropBlur().clipShape(.capsule))
    }
}

#Preview("MomensMainTabBar - Variants") {
    VStack(spacing: 12) {
        ForEach(MainTab.allCases, id: \.self) { selectedTab in
            ZStack {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(0..<4) { _ in
                        Text("시그널 브리프 태스크 회의록 업데이트 프로젝트 멤버")
                            .foregroundStyle(MomensColor.gray800)
                            .momensFont(.bodyM14)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(width: 340, height: 88, alignment: .topLeading)
                .background(MomensColor.uiBackground)

                MomensMainTabBar(selectedTab: selectedTab, onTabClick: { _ in })
            }
        }
    }
    .padding(20)
}
