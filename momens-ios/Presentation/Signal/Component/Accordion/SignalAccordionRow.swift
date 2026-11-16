import SwiftUI

struct SignalAccordionRow: View {
    let item: SignalAccordionItem

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            Text(item.title)
                .momensFont(.bodyB12)
                .foregroundStyle(MomensColor.gray900)
                .frame(width: 31, alignment: .leading)

            Text(item.value)
                .momensFont(.bodyM12)
                .foregroundStyle(MomensColor.gray400)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 18, alignment: .top)
        .accessibilityElement(children: .combine)
    }
}
