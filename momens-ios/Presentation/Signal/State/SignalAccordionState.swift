struct SignalAccordionState: Equatable {
    let items: [SignalAccordionItem]
    private(set) var expanded: Bool

    init(items: [SignalAccordionItem], initiallyExpanded: Bool) {
        self.items = items
        expanded = initiallyExpanded
    }

    mutating func toggle() {
        expanded.toggle()
    }
}
