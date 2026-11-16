struct SignalAccordionState: Equatable {
    let items: [SignalAccordionItem]
    private(set) var expanded: Bool

    init(items: [SignalAccordionItem]) {
        self.items = items
        expanded = items.count <= 2
    }

    mutating func toggle() {
        expanded.toggle()
    }
}
