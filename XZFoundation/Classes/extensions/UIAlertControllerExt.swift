//
//  UIAlertControllerExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/14.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public typealias LKAlertAction = (_ buttonTitle: String) -> Void

public extension XZ where Base: UIAlertController{
    @discardableResult
    class func showWithSystemStyle(title: String, msg: String?, prefferStyle: UIAlertController.Style = .alert, buttons: [String] = ["确定"], actionBlock: LKAlertAction? = nil) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: prefferStyle)
        if buttons.count > 0 {
            let cancel = UIAlertAction(title: buttons[0], style: .cancel) { (action) in
                actionBlock?(buttons[0])
            }
            alert.addAction(cancel)
        }
        if buttons.count > 1 {
            let ok = UIAlertAction(title: buttons[1], style: .default) { (action) in
                actionBlock?(buttons[1])
            }
            alert.addAction(ok)
        }
        alert.xz.show()
        return alert
    }
    
    func show(completion: (()->Void)? = nil) {
        UIWindow.xz.topController()?.present(base, animated: true, completion: completion)
    }
}

//extension UIAlertController {
//    static func withCancelAction(
//        title: String?,
//        message: String?,
//        preferredStyle: UIAlertController.Style,
//        cancelActionTitle: String = "cancel".localized,
//        cancelActionStyle: UIAlertAction.Style = .cancel,
//        cancelActionHandler: ((UIAlertAction) -> Void)? = nil
//    ) -> UIAlertController {
//        let alertController = UIAlertController(
//            title: title, message: message, preferredStyle: preferredStyle)
//        let cancelAction = UIAlertAction(
//            title: "cancel".localized,
//            style: cancelActionStyle,
//            handler: cancelActionHandler)
//        alertController.addAction(cancelAction)
//        return alertController
//    }
//
//    static var noAppCanHandleAlert: UIAlertController {
//        let alertController = UIAlertController( title: nil, message: "no_app_can_handle".localized, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
//        return alertController
//    }
//
//    static func alert(title: String?, message: String?, textFieldHandler: ((UIAlertController, UITextField) -> Void)?, actions: UIAlertAction...) -> UIAlertController {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.view.tintColor = UIColor.text.accent
//        if textFieldHandler != nil{
//            alert.addTextField { (textField) in
//                textFieldHandler?(alert, textField)
//            }
//        }
//        actions.forEach{alert.addAction($0)}
//        return alert
//    }
//
//    static func alert(title: String?, message: String?, actions: UIAlertAction...) -> UIAlertController {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.view.tintColor = UIColor.text.accent
//        actions.forEach{alert.addAction($0)}
//        return alert
//    }
//
//    static func actionSheet(title: String?, message: String?, actions: UIAlertAction...) -> UIAlertController {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//        alert.view.tintColor = UIColor.text.accent
//        actions.forEach{alert.addAction($0)}
//        return alert
//    }
//
//    static func actionSheetDatePicker(title: String?, date: Date?, dateHandler: ((Date) -> Void)?, actions: (_ handler: (((UIAlertAction) -> Void)?)) -> [UIAlertAction]) -> UIAlertController {
//        let picker = UIDatePicker()
//        picker.datePickerMode = .date
//        picker.minimumDate = Date(timeIntervalSince1970: 0)
//        picker.maximumDate = Date()
//        // 设置日期
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let defaultDate = dateFormatter.date(from: "2000-01-01")
//        picker.setDate(date ?? defaultDate ?? Date(), animated: true)
//        let alert = UIAlertController(title: title, message: "\n\n\n\n\n\n\n\n\n", preferredStyle: .actionSheet)
//        alert.view.tintColor = UIColor.text.accent
//        actions { (action) in
//            dateHandler?(picker.date)
//        }.forEach{alert.addAction($0)}
//        alert.view.addSubview(picker)
//        picker.snp.makeConstraints { (make) in
//            make.top.left.right.equalToSuperview()
//            make.height.equalTo(200)
//        }
//        return alert
//    }
//
//    func set(vc: UIViewController?, width: CGFloat? = nil, height: CGFloat? = nil) {
//        guard let vc = vc else { return }
//        setValue(vc, forKey: "contentViewController")
//        if let height = height {
//            vc.preferredContentSize.height = height
//            preferredContentSize.height = height
//        }
//    }
//}
