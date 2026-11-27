import SwiftUI

struct BriefDropdown: View {
    let items: [BriefSignalItemUiModel]
    let hasMore: Bool
    let canLoadMore: Bool
    let isExpanded: Bool
    let onMoreClick: () -> Void
    let onLoadMore: () -> Void
    let onFoldClick: () -> Void

    @State private var rowsHeight: CGFloat?
    @State private var extraHeight: CGFloat?

    private static let maxVisibleCount = 3
    private static let contentMaxHeight: CGFloat = 156
    private static let contentVerticalPadding: CGFloat = 16
    private static let toggleAnimation: Animation = .spring(response: 0.3, dampingFraction: 1)

    private var defaultItems: [BriefSignalItemUiModel] {
        Array(items.prefix(Self.maxVisibleCount))
    }

    private var expandableItems: [BriefSignalItemUiModel] {
        Array(items.dropFirst(Self.maxVisibleCount))
    }

    private var showToggleButton: Bool {
        hasMore || isExpanded || !expandableItems.isEmpty
    }

    private var viewportHeight: CGFloat? {
        guard let rowsHeight, let extraHeight else { return nil }
        let contentHeight = rowsHeight + (isExpanded ? extraHeight : 0) + Self.contentVerticalPadding * 2
        return min(contentHeight, Self.contentMaxHeight)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(defaultItems) { BriefDropdownRow(item: $0) }
                    }
                    .onGeometryChange(
                        for: CGFloat.self,
                        of: { $0.size.height },
                        action: { rowsHeight = $0 }
                    )

                    expandableRows
                        .onGeometryChange(
                            for: CGFloat.self,
                            of: { $0.size.height },
                            action: { extraHeight = $0 }
                        )
                        .frame(height: isExpanded ? extraHeight : 0, alignment: .top)
                        .clipped()
                        .opacity(isExpanded ? 1 : 0)
                        .accessibilityHidden(!isExpanded)

                    if isExpanded && canLoadMore {
                        Color.clear
                            .frame(height: 1)
                            .onAppear(perform: onLoadMore)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, Self.contentVerticalPadding)
            }
            .frame(height: viewportHeight)
            .scrollBounceBehavior(.basedOnSize)

            if showToggleButton {
                Rectangle()
                    .fill(MomensColor.gray100)
                    .frame(height: 1)

                toggleButton
            }
        }
        .background(MomensColor.white, in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(MomensColor.gray100, lineWidth: 1)
        }
        .animation(Self.toggleAnimation, value: isExpanded)
    }

    private var expandableRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(expandableItems) { BriefDropdownRow(item: $0) }
        }
        .padding(.top, expandableItems.isEmpty ? 0 : 16)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var toggleButton: some View {
        HStack(spacing: 2) {
            Text(isExpanded ? "접기" : "더보기")
                .momensFont(.captionB11)
                .contentTransition(.identity)

            Image("ic_next")
                .renderingMode(.template)
                .resizable()
                .frame(width: 16, height: 16)
                .rotationEffect(.degrees(isExpanded ? 270 : 90))
        }
        .foregroundStyle(MomensColor.gray400)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .contentShape(.rect)
        .onTapGesture {
            if isExpanded {
                onFoldClick()
            } else {
                onMoreClick()
            }
        }
        .accessibilityAddTraits(.isButton)
    }
}

private struct BriefDropdownRow: View {
    let item: BriefSignalItemUiModel

    var body: some View {
        HStack(spacing: 8) {
            MomensDot(size: 6, color: item.type.signalColor)

            Text(item.title)
                .momensFont(.captionB11)
                .foregroundStyle(MomensColor.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct BriefDropdownPreview: View {
    @State private var isTwoItemExpanded = false
    @State private var isManyItemExpanded = false

    private let twoItems = [
        BriefSignalItemUiModel(id: "1", type: .decision, title: "소셜 로그인은 MVP 범위에서 제외"),
        BriefSignalItemUiModel(id: "2", type: .decision, title: "회원가입 MVP 범위 1차 확정")
    ]

    private let manyItems = [
        BriefSignalItemUiModel(id: "1", type: .decision, title: "소셜 로그인은 MVP 범위에서 제외"),
        BriefSignalItemUiModel(id: "2", type: .decision, title: "회원가입 MVP 범위 1차 확정"),
        BriefSignalItemUiModel(id: "3", type: .risk, title: "Android13+ 권한 요청 플로우 이탈 가능성"),
        BriefSignalItemUiModel(id: "4", type: .question, title: "푸시 알림 정책 논의 필요"),
        BriefSignalItemUiModel(id: "5", type: .question, title: "로그인 유지 기간 결정 필요")
    ]

    var body: some View {
        VStack(spacing: 24) {
            BriefDropdown(
                items: twoItems,
                hasMore: false,
                canLoadMore: false,
                isExpanded: isTwoItemExpanded,
                onMoreClick: { isTwoItemExpanded = true },
                onLoadMore: {},
                onFoldClick: { isTwoItemExpanded = false }
            )

            BriefDropdown(
                items: manyItems,
                hasMore: true,
                canLoadMore: false,
                isExpanded: isManyItemExpanded,
                onMoreClick: { isManyItemExpanded = true },
                onLoadMore: {},
                onFoldClick: { isManyItemExpanded = false }
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(MomensColor.gray200)
    }
}

#Preview("BriefDropdown") {
    BriefDropdownPreview()
}
