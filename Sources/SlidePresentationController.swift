//
//  SlidePresentAnimationController.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/28/17.
//

import UIKit

class SlidePresentationController: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame = CGRect.zero
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard /* let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from), */
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }

        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrame(for: toVC)

        containerView.addSubview(toVC.view)
        
        toVC.view.frame = initialFrame
        UIView.animate(
            withDuration:  transitionDuration(using: transitionContext),
            animations: {
                toVC.view.frame = finalFrame
        }, completion: { _  in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
