import SwiftUI
import UIKit

struct MomensBackdropBlur: UIViewRepresentable {
    var intensity: CGFloat = MomensEffect.navigationBlurIntensity

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: nil)
        context.coordinator.attach(to: view, intensity: intensity)
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        context.coordinator.update(intensity: intensity)
    }

    final class Coordinator {
        private var animator: UIViewPropertyAnimator?

        func attach(to view: UIVisualEffectView, intensity: CGFloat) {
            let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
                view.effect = UIBlurEffect(style: .regular)
            }
            animator.pausesOnCompletion = true
            animator.fractionComplete = intensity
            self.animator = animator
        }

        func update(intensity: CGFloat) {
            animator?.fractionComplete = intensity
        }

        deinit {
            animator?.stopAnimation(true)
        }
    }
}
