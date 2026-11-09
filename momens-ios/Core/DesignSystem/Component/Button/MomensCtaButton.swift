import SwiftUI

struct MomensCtaButton<Content: View>: View {
    let action: () -> Void
    var type: MomensCtaType = .default
    var isEnabled = true
    @ViewBuilder let content: () -> Content

    private var backgroundColor: Color {
        guard isEnabled else { return MomensColor.gray300 }
        switch type {
        case .default:
            return MomensColor.primary100
        case .login:
            return MomensColor.white
        case .cancel:
            return MomensColor.gray300
        }
    }

    var body: some View {
        Button(action: action) {
            content()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundColor, in: .rect(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview("MomensCtaButton - Variants") {
    VStack(spacing: 10) {
        MomensCtaButton(action: {}, content: {
            Text("text")
                .foregroundStyle(MomensColor.white)
                .momensFont(.bodyB16)
        })

        MomensCtaButton(action: {}, isEnabled: false, content: {
            Text("text")
                .foregroundStyle(MomensColor.white)
                .momensFont(.bodyB16)
        })

        MomensCtaButton(action: {}, type: .cancel, content: {
            Text("text")
                .foregroundStyle(MomensColor.gray700)
                .momensFont(.bodyB16)
        })

        MomensCtaButton(action: {}, type: .login, content: {
            HStack(spacing: 8) {
                Image("ic_google")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("text")
                    .foregroundStyle(MomensColor.gray700)
                    .momensFont(.bodyB16)
            }
        })
    }
    .padding(16)
    .frame(width: 352)
    .background(MomensColor.gray100)
}
