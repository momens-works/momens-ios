import SwiftUI

struct SignalAccordion: View {
    let type: SignalAccordionType
    let time: String
    let items: [SignalAccordionItem]

    @State private var expanded: Bool

    init(
        type: SignalAccordionType,
        time: String,
        items: [SignalAccordionItem],
        initiallyExpanded: Bool = false
    ) {
        self.type = type
        self.time = time
        self.items = items
        _expanded = State(initialValue: initiallyExpanded)
    }

    var body: some View {
        VStack(spacing: 0) {
            SignalAccordionHeader(type: type, time: time, expanded: expanded) {
                withAnimation(.smooth(duration: 0.3)) {
                    expanded.toggle()
                }
            }

            if expanded {
                SignalAccordionContent(items: items)
                    .transition(.opacity)
            }
        }
        .clipped()
    }
}

#if DEBUG
private let accordionPreviewItems: [SignalAccordionItem] = [
    .init(id: "target", title: "대상", value: "권한 요청 화면"),
    .init(id: "change", title: "변화", value: "권한 요청 단계 이탈률이 오른 것으로 보임"),
    .init(id: "impact", title: "영향", value: "회원가입 완료율이 떨어질 수 있음")
]

private struct SignalAccordionPreview: View {
    let items: [SignalAccordionItem]
    let initiallyExpanded: Bool

    var body: some View {
        SignalAccordion(
            type: .figma,
            time: "30분 전",
            items: items,
            initiallyExpanded: initiallyExpanded
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
