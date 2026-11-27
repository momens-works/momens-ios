import SwiftUI
import UIKit

struct TaskEditCompletionRuleInput: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool

    static let maximumCount = 50

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        let typography = MomensTypography.bodyM12
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = typography.uiLineHeight
        paragraph.maximumLineHeight = typography.uiLineHeight
        view.typingAttributes = [
            .font: typography.uiFont,
            .foregroundColor: UIColor(MomensColor.gray800),
            .kern: typography.tracking,
            .paragraphStyle: paragraph
        ]
        view.font = typography.uiFont
        view.textColor = UIColor(MomensColor.gray800)
        view.backgroundColor = .clear
        view.tintColor = UIColor(MomensColor.gray800)
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.text = text
        view.delegate = context.coordinator

        let placeholder = context.coordinator.placeholder
        placeholder.text = "완료 기준을 기재해주세요"
        placeholder.font = typography.uiFont
        placeholder.textColor = UIColor(MomensColor.gray300)
        placeholder.isUserInteractionEnabled = false
        placeholder.isHidden = !text.isEmpty
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placeholder.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        // SwiftUI updates must not overwrite the keyboard's unfinished composition.
        if view.markedTextRange == nil, view.text != text {
            coordinator.isSynchronizing = true
            view.text = text
            coordinator.accept(view)
            coordinator.isSynchronizing = false
        }
        coordinator.placeholder.isHidden = !view.text.isEmpty
        if view.isFirstResponder != isFocused {
            DispatchQueue.main.async {
                if coordinator.parent.isFocused {
                    view.becomeFirstResponder()
                } else {
                    view.resignFirstResponder()
                }
            }
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width else { return nil }
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(MomensTypography.bodyM12.uiLineHeight, size.height))
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: TaskEditCompletionRuleInput
        let placeholder = UILabel()
        var isSynchronizing = false
        private var acceptedText: String
        private var acceptedSelection = NSRange(location: 0, length: 0)

        init(parent: TaskEditCompletionRuleInput) {
            self.parent = parent
            acceptedText = parent.text
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText: String) -> Bool {
            // Allow the IME to finish composing before validating its result.
            guard textView.markedTextRange == nil else { return true }
            guard let range = Range(range, in: textView.text) else { return false }
            let candidate = textView.text.replacingCharacters(in: range, with: replacementText)
            if candidate.count <= TaskEditCompletionRuleInput.maximumCount {
                acceptedSelection = textView.selectedRange
                return true
            }
            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            synchronize(textView)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            synchronize(textView)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            synchronize(textView)
            parent.isFocused = false
        }

        private func synchronize(_ view: UITextView) {
            guard !isSynchronizing else { return }
            placeholder.isHidden = !view.text.isEmpty
            view.invalidateIntrinsicContentSize()
            guard view.markedTextRange == nil else { return }
            if view.text.count <= TaskEditCompletionRuleInput.maximumCount {
                accept(view)
                if parent.text != view.text {
                    parent.text = view.text
                }
            } else {
                // Reject an over-limit commit; preserve the original text and cursor.
                isSynchronizing = true
                view.text = acceptedText
                view.selectedRange = acceptedSelection
                placeholder.isHidden = !acceptedText.isEmpty
                isSynchronizing = false
            }
        }

        func accept(_ view: UITextView) {
            acceptedText = view.text
            acceptedSelection = view.selectedRange
        }
    }
}
