//
//  InteractiveController..swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/28/17.
//

import UIKit

class InteractiveControllerPresentation: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false
    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    
    func wireToViewController(viewController: UIViewController!, view: UIView) {
        self.viewController = viewController
        prepareGestureRecognizerInView(view: view)
    }
    
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture))
        view.addGestureRecognizer(gesture)
    }
    
    func handleGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let view = viewController.view!
        let translation = gestureRecognizer.translation(in: view)
        let distance = fabs(translation.y) / view.bounds.height
        let amount = fmaxf(Float(distance), 0.0)
        let percent = fminf(amount, 1.0) * 3.0
        let progress = CGFloat(percent)

        NSLog("progress present \(progress) \(translation.y)")
        
        switch gestureRecognizer.state {
            
        case .began:
            interactionInProgress = true
            viewController.present()
            
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

