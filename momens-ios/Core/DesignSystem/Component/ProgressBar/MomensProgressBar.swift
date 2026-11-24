import SwiftUI

struct MomensProgressBar: View {
    let progress: Double

    private var fraction: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(MomensColor.white)
                .frame(width: max(proxy.size.width * fraction, 14))
                .overlay(alignment: .trailing) {
                    Circle()
                        .fill(MomensColor.primary50)
                        .frame(width: 6, height: 6)
                        .padding(.trailing, 4)
                }
        }
        .frame(height: 12)
        .background(MomensColor.primary50, in: .capsule)
    }
}

#Preview("MomensProgressBar - Variants") {
    VStack(spacing: 24) {
        ForEach(0...10, id: \.self) { step in
            MomensProgressBar(progress: Double(step) / 10)
        }
    }
    .padding(16)
    .background(MomensColor.gray200)
}
