import UIKit

class TransitioningAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let duration = 0.3

    init(frame: CGRect) {
        self.frame = frame
    }

    var frame: CGRect

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toController = transitionContext.viewController(forKey: .to) as? UINavigationController else {
            transitionContext.completeTransition(true)
            return
        }

        let container = transitionContext.containerView
        container.addSubview(toController.view)

        guard let toSnapshot = toController.view.snapshotView(afterScreenUpdates: true) else {
            transitionContext.completeTransition(true)
            return
        }
        container.addSubview(toSnapshot)

        let initialPosition = CGPoint(x: frame.midX, y: frame.midY)
        let initialScale = frame.height / toSnapshot.bounds.height

        toSnapshot.center = initialPosition
        toSnapshot.transform = CGAffineTransform.identity.scaledBy(x: 1, y: initialScale)
        toController.view.alpha = 0.0

        UIView.animate(withDuration: duration) {
            toSnapshot.center = toController.view.center
            toSnapshot.transform = .identity
            toController.view.alpha = 1.0
        } completion: { _ in
            toSnapshot.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }

}
