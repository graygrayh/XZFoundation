//
//  UIViewControllerExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UIViewController {
    
    func attachChild(_ child: UIViewController, toContainerView containerView: UIView? = nil, withLayout: Bool = true) {
        let container: UIView = containerView ?? base.view
        base.addChild(child)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(child.view)
        
        if withLayout {
            NSLayoutConstraint.activate([
                child.view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
                child.view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
                child.view.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
                child.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
            ])
        }
        child.didMove(toParent: base)
    }
    
    
    /// Helper method to remove self from parent
    func dettachFromParent() {
        guard base.parent != nil else { return }
        
        base.willMove(toParent: nil)
        base.view.removeFromSuperview()
        base.removeFromParent()
    }
    
}

//public extension UIViewController {
//
//    /// Helper method to display an alert on any UIViewController subclass. Uses UIAlertController to show an alert
//    ///
//    /// - Parameters:
//    ///   - title: title of the alert
//    ///   - message: message/body of the alert
//    ///   - buttonTitles: (Optional)list of button titles for the alert. Default button i.e "OK" will be shown if this paramter is nil
//    ///   - highlightedButtonIndex: (Optional) index of the button from buttonTitles that should be highlighted. If this parameter is nil no button will be highlighted
//    ///   - completion: (Optional) completion block to be invoked when any one of the buttons is tapped. It passes the index of the tapped button as an argument
//    /// - Returns: UIAlertController object (discardable).
//    @discardableResult
//    func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) -> UIAlertController {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        var allButtons = buttonTitles ?? [String]()
//        if allButtons.count == 0 {
//            allButtons.append("OK")
//        }
//
//        for index in 0..<allButtons.count {
//            let buttonTitle = allButtons[index]
//            let action = UIAlertAction(title: buttonTitle, style: .default, handler: { (_) in
//                completion?(index)
//            })
//            alertController.addAction(action)
//            // Check which button to highlight
//            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
//                alertController.preferredAction = action
//            }
//        }
//        present(alertController, animated: true, completion: nil)
//        return alertController
//    }
//
//
//    #if os(iOS)
//    /// Helper method to present a UIViewController as a popover.
//    ///
//    /// - Parameters:
//    ///   - popoverContent: the view controller to add as a popover.
//    ///   - sourcePoint: the point in which to anchor the popover.
//    ///   - size: the size of the popover. Default uses the popover preferredContentSize.
//    ///   - delegate: the popover's presentationController delegate. Default is nil.
//    ///   - animated: Pass true to animate the presentation; otherwise, pass false.
//    ///   - completion: The block to execute after the presentation finishes. Default is nil.
//    func presentPopover(_ popoverContent: UIViewController, sourcePoint: CGPoint, size: CGSize? = nil, delegate: UIPopoverPresentationControllerDelegate? = nil, animated: Bool = true, completion: (() -> Void)? = nil) {
//
//        popoverContent.modalPresentationStyle = .popover
//
//        if let size = size {
//            popoverContent.preferredContentSize = size
//        }
//
//        if let popoverPresentationVC = popoverContent.popoverPresentationController {
//            popoverPresentationVC.sourceView = view
//            popoverPresentationVC.sourceRect = CGRect(origin: sourcePoint, size: .zero)
//            popoverPresentationVC.delegate = delegate
//        }
//
//        present(popoverContent, animated: animated, completion: completion)
//    }
//    #endif
//
//}


public extension XZ where Base: UIViewController  {
    
    var isPresented: Bool {
        if let index = base.navigationController?.viewControllers.firstIndex(of: base), index > 0 {
            return false
        } else if base.presentingViewController != nil {
            return true
        } else if base.navigationController?.presentingViewController?.presentedViewController == base.navigationController {
            return true
        } else if base.tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    func disableAdjustsScrollViewInsets(_ scrollView: UIScrollView) {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            base.automaticallyAdjustsScrollViewInsets = false
        }
    }
}
