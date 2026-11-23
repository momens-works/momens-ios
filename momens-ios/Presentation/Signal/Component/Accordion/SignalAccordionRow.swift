import SwiftUI

struct SignalAccordionRow: View {
    let item: SignalAccordionItem

    private var displayedValue: String {
        let maximumLength = 40
        guard item.value.count > maximumLength else { return item.value }
        return String(item.value.prefix(maximumLength - 1)) + "…"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Text(item.title)
                .momensFont(.bodyB12)
                .foregroundStyle(MomensColor.gray900)
                .frame(width: 31, alignment: .leading)

            Text(displayedValue)
                .momensFont(.bodyM12)
                .foregroundStyle(MomensColor.gray500)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 18, alignment: .top)
        .accessibilityElement(children: .combine)
    }
}
