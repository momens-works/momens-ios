import SwiftUI

struct SignalAccordion: View {
    let type: SignalAccordionType
    let time: String
    let state: SignalAccordionState
    let onToggle: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            SignalAccordionHeader(type: type, time: time, expanded: state.expanded, onClick: onToggle)

            if state.expanded {
                SignalAccordionContent(items: state.items)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .clipped()
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: state.expanded)
    }
}

#if DEBUG
private let accordionPreviewItems: [SignalAccordionItem] = [
    .init(id: "target", title: "대상", value: "권한 요청 화면"),
    .init(id: "change", title: "변화", value: "권한 요청 단계 이탈률이 오른 것으로 보임"),
    .init(id: "impact", title: "영향", value: "회원가입 완료율이 떨어질 수 있음")
]

private struct SignalAccordionPreview: View {
    @State private var state: SignalAccordionState

    init(items: [SignalAccordionItem]) {
        _state = State(initialValue: SignalAccordionState(items: items))
    }

    var body: some View {
        SignalAccordion(
            type: .figma,
            time: "30분 전",
            state: state,
            onToggle: { state.toggle() }
        )
        .padding(16)
    }
}

#Preview("Accordion - Three Items Initially Collapsed") {
    SignalAccordionPreview(items: accordionPreviewItems)
}

#Preview("Accordion - Two Items Initially Expanded") {
    SignalAccordionPreview(items: Array(accordionPreviewItems.prefix(2)))
}

#Preview("Accordion - Many Items Scroll") {
    SignalAccordionPreview(items: (0..<10).map { index in
        SignalAccordionItem(id: "item-\(index)", title: "항목", value: "스크롤 콘텐츠 \(index + 1)")
    })
}

#Preview("Accordion - Sources and States") {
    VStack(spacing: 20) {
        ForEach(SignalAccordionType.allCases, id: \.self) { type in
            SignalAccordion(
                type: type,
                time: "12분 전",
                state: SignalAccordionState(items: accordionPreviewItems),
                onToggle: {}
            )
        }
    }
    .padding(16)
}

#Preview("Accordion - Narrow and Long Text") {
    SignalAccordion(
        type: .slack,
        time: "방금 전",
        state: SignalAccordionState(items: [
            .init(id: "long", title: "변화", value: String(repeating: "길이가 긴 내용이 여러 줄로 표시됩니다. ", count: 4)),
            .init(id: "duplicate", title: "변화", value: "동일한 제목을 가진 별개의 행")
        ]),
        onToggle: {}
    )
    .frame(width: 260)
    .padding(16)
}

#Preview("Accordion - Empty") {
    SignalAccordion(type: .file, time: "1시간 전", state: SignalAccordionState(items: []), onToggle: {})
        .padding(16)
}
#endif
