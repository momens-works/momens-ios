import SwiftUI

struct SignalAccordionContent: View {
    let items: [SignalAccordionItem]

    var body: some View {
        rows
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            MomensColor.gray100,
            in: UnevenRoundedRectangle(bottomLeadingRadius: 8, bottomTrailingRadius: 8)
        )
    }

    private var rows: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(items) { item in
                    SignalAccordionRow(item: item)
                }
            }
            Spacer(minLength: 0)
        }
    }
}
