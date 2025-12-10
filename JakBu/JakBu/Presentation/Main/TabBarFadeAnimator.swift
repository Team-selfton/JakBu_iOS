import UIKit

class TabBarFadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25 // A quarter of a second for a subtle fade
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }

        let containerView = transitionContext.containerView
        
        // Add the 'to' view to the container
        containerView.addSubview(toView)
        
        // Set initial state
        toView.alpha = 0.0

        // Perform the animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseInOut, animations: {
            toView.alpha = 1.0
        }) { finished in
            // When the animation is finished, we must call completeTransition(_:)
            // to let the system know that the transition is complete.
            fromView.alpha = 1.0 // Reset fromView alpha just in case
            transitionContext.completeTransition(finished)
        }
    }
}
