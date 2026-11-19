import SwiftUI

struct MomensQuestionBox: View {
    enum Style {
        case `default`
        case line
    }

    let text: String
    var style: Style = .default

    var body: some View {
        HStack(spacing: 8) {
            Image(decorative: "ic_question")
                .foregroundStyle(MomensColor.primary100)

            Text(text)
                .momensFont(.bodyM12)
                .foregroundStyle(MomensColor.gray800)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .overlay(alignment: .bottom) {
            if style == .line {
                Rectangle()
                    .fill(MomensColor.gray100)
                    .frame(height: 1)
            }
        }
    }
}

#Preview("Question Box Styles") {
    let question = "약한 비밀번호 기준을 사용자에게 얼마나 구체적으로 알려줘야할 지 결정이 필요해보임"

    VStack(alignment: .leading, spacing: 20) {
        MomensQuestionBox(text: question)
        MomensQuestionBox(text: question, style: .line)
    }
    .frame(width: 343)
}
