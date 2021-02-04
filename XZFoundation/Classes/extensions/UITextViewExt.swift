//
//  UITextViewExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/9.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UITextView {
    func removeTextPadding() {
        base.textContainer.lineFragmentPadding = 0
        base.textContainerInset = .zero
    }
    
    var wholeRange: NSRange {
        .init(location: 0, length: base.attributedText.length)
    }
    
    func textInRange(_ nsRange: NSRange) -> String? {
        let string = base.attributedText.string
        guard let range = Range<String.Index>(nsRange, in: string) else { return nil }
        return String(string[range])
    }
    
    func nsRangeFromTextRange(_ textRange: UITextRange) -> NSRange {
        let location = base.offset(from: base.beginningOfDocument, to: textRange.start)
        let length = base.offset(from: textRange.start, to: textRange.end)
        return .init(location: location, length: length)
    }
    
    var markedRange: NSRange? {
        guard let markedTextRange = base.markedTextRange else { return nil }
        return nsRangeFromTextRange(markedTextRange)
    }
}


/// Extend UITextView and implemented UITextViewDelegate to listen for changes
//extension UITextView {
//
//    private var placeHolderTag: Int {
//        100
//    }
//
//    /// Resize the placeholder when the UITextView bounds change
//    override open var bounds: CGRect {
//        didSet {
//            self.resizePlaceholder()
//        }
//    }
//
//    /// The UITextView placeholder text
//    public var placeholder: String? {
//        get {
//            var placeholderText: String?
//
//            if let placeholderLabel = self.viewWithTag(placeHolderTag) as? UILabel {
//                placeholderText = placeholderLabel.text
//            }
//
//            return placeholderText
//        }
//        set {
//            if let placeholderLabel = self.viewWithTag(placeHolderTag) as? UILabel {
//                placeholderLabel.text = newValue
//                placeholderLabel.sizeToFit()
//            } else {
//                self.addPlaceholder(newValue!)
//            }
//        }
//    }
//
//    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
//    ///
//    /// - Parameter textView: The UITextView that got updated
//    public func handleChangeInTextView(_ textView: UITextView) {
//        if let placeholderLabel = self.viewWithTag(placeHolderTag) as? UILabel {
//            placeholderLabel.isHidden = self.text.count > 0
//        }
//    }
//
//    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
//    private func resizePlaceholder() {
//        if let placeholderLabel = self.viewWithTag(placeHolderTag) as? UILabel {
//            let labelX = self.textContainer.lineFragmentPadding + 5
//            let labelY = self.textContainerInset.top - 2
//            let labelWidth = self.frame.width - (labelX * 2)
//            let labelHeight = placeholderLabel.frame.height
//
//            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
//        }
//    }
//
//    /// Adds a placeholder UILabel to this UITextView
//    private func addPlaceholder(_ placeholderText: String) {
//        let placeholderLabel = UILabel()
//
//        placeholderLabel.text = placeholderText
//        placeholderLabel.sizeToFit()
//
//        placeholderLabel.font = self.font
//        placeholderLabel.textColor = UIColor.lightGray
//        placeholderLabel.tag = placeHolderTag
//
//        placeholderLabel.isHidden = self.text.count > 0
//
//        self.addSubview(placeholderLabel)
//        self.resizePlaceholder()
//    }
//
//}
