//
//  BannerTabViewController.swift
//  Dining
//
//  Created by Paul Ossenbruggen on 2/25/17.
//

import UIKit

@objc class BannerTabBarController: UITabBarController, UIViewControllerTransitioningDelegate {
    private var bannerView : UIVisualEffectView?
    
    private let interactiveControllerPresentation = InteractiveControllerPresentation()
    private let interactiveControllerDismissal = InteractiveControllerDismissal()

    fileprivate let slidePresentationController = SlidePresentationController()
    fileprivate let slideDismissController = SlideDismissController()

    override func viewDidLoad() {
        let frame = tabBar.frame
        let frameAbove = CGRect(x: frame.origin.x,
                                y: frame.origin.y - frame.size.height,
                                width: frame.width,
                                height: frame.height)
        let effect = UIBlurEffect(style: .regular)
        let bannerView = UIVisualEffectView(effect: effect)
        self.bannerView = bannerView
        bannerView.isUserInteractionEnabled = true
        bannerView.frame = frameAbove
        view.addSubview(bannerView)
        
        let tap = UITapGestureRecognizer(
            target: self,
            action:#selector(tapAction))
        bannerView.addGestureRecognizer(tap)
        
        let reservationDataManager = ReservationDataManager.shared
        reservationDataManager.fetchReservations()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        label.textAlignment = .center
        label.text = reservationDataManager.reservations[0].restaurant.name
        label.textColor = UIColor.black
        bannerView.addSubview(label)
        
        interactiveControllerPresentation.wireToViewController(viewController: self, view: bannerView)
    }
    
    func tapAction(sender : UITapGestureRecognizer) {
        present()
    }
    
    override func present() {
        performSegue(withIdentifier: "ReservationController", sender:self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReservationController",
            let destinationViewController = segue.destination as? ReservationTableViewController,
            let sourceViewController = segue.source as? BannerTabBarController {
            
            // force view to load.
            _ = destinationViewController.view
			
            destinationViewController.transitioningDelegate = self
            
            interactiveControllerDismissal.wireToViewControllers(dismissViewController: destinationViewController,
                                                                 originalViewController: sourceViewController,
                                                                 view: destinationViewController.grabArea)
            
        }
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveControllerDismissal.interactionInProgress ? interactiveControllerDismissal : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveControllerPresentation.interactionInProgress ? interactiveControllerPresentation : nil
    }


    func animationController(forPresented: UIViewController,
                             presenting:UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slidePresentationController.originFrame = bannerView?.frame ?? CGRect.zero
        return slidePresentationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        slideDismissController.destinationFrame = bannerView?.frame ?? CGRect.zero
        return slideDismissController
    }
}

extension UIViewController {
    func present() {
        // override
    }
}

