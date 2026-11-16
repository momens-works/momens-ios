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

    init(items: [SignalAccordionItem], initiallyExpanded: Bool) {
        _state = State(initialValue: SignalAccordionState(items: items, initiallyExpanded: initiallyExpanded))
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

#Preview("Accordion - Initially Collapsed") {
    SignalAccordionPreview(items: accordionPreviewItems, initiallyExpanded: false)
}

#Preview("Accordion - Initially Expanded") {
    SignalAccordionPreview(items: accordionPreviewItems, initiallyExpanded: true)
}

#endif
