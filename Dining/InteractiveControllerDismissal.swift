//
//  InteractiveController..swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/28/17.
//

import UIKit

class InteractiveControllerDismissal: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var dismissViewController: UIViewController!


    func wireToViewControllers(dismissViewController: UIViewController!, originalViewController: UIViewController, view: UIView) {
        self.dismissViewController = dismissViewController
        prepareGestureRecognizerInView(view: view)
    }

    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        view.addGestureRecognizer(gesture)
    }

    @objc func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let view = dismissViewController.view!
        let translation = gestureRecognizer.translation(in: view)
        let distance = translation.y / view.bounds.height
        let amount = fmaxf(Float(distance), 0.0)
        let percent = fminf(amount, 1.0)
        let progress = CGFloat(percent)
        
        NSLog("progress dismiss \(progress)  \(translation.y)")
  
        switch gestureRecognizer.state {
            
        case .began:
            interactionInProgress = true
            dismissViewController.dismiss(animated: true, completion: nil)
            
        case .changed:
            shouldCompleteTransition = progress > 0.5
            update(progress)
            
        case .cancelled:
            interactionInProgress = false
            cancel()
            
        case .ended:
            interactionInProgress = false
            
            if !shouldCompleteTransition {
                cancel()
            } else {
                finish()
            }
            
        default:
            print("Unsupported")
        }
    }
}

