//
//  UIImageExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/5.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit

public extension XZ where Base: UIImage {
    
    /// Base 64 encoded PNG data of the image as a String
    func pngBase64String() -> String? {
        return base.pngData()?.base64EncodedString()
    }
    
    /// Base 64 encoded JPEG data of the image as a String
    func jpegBase64String(compressionQuality: CGFloat) -> String? {
        return base.jpegData(compressionQuality: compressionQuality)?.base64EncodedString()
    }
}

public extension XZ where Base: UIImage {
    
    ///Compressed UIImage from original UIImage
    /// - Parameter quality: 0.0~1.0  (default is 0.8)
    func compressed(quality: CGFloat = 0.8) -> UIImage? {
        guard let data = base.jpegData(compressionQuality: quality) else { return nil }
        return UIImage(data: data)
    }
    
    /// Compressed UIImage data from original UIImage
    /// - Parameter quality: 0.0~1.0  (default is 0.8)
    func compressedData(quality: CGFloat = 0.8) -> Data? {
        return base.jpegData(compressionQuality: quality)
    }
    
    func resized(_ dimension: CGFloat, opaque: Bool = true,
                     contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = base.size
        let aspectRatio = size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {
                // Landscape image
                if size.width <= dimension {
                    return base
                }
                width = dimension
                height = dimension / aspectRatio
            } else {
                // Portrait image
                if size.height <= dimension {
                    return base
                }
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIImage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                base.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            base.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func compressTo(maxLength: Int64, _ maxCycle: Int = 6) -> Data {
        var compression: CGFloat = 1
        var data = base.jpegData(compressionQuality: compression)!
        if data.count < maxLength {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        var bestData: Data = data
        for _ in 0..<maxCycle {
            compression = (max + min)/2
            data = base.jpegData(compressionQuality: compression)!
            if Double(data.count) < Double(maxLength)*0.9 {
                min = compression
                bestData = data
            } else if data.count > maxLength {
                max = compression
            } else {
                bestData = data
                break
            }
        }
        return bestData
    }
    
}

public extension UIImage {
    
    /// Create UIImage from color and size
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }
        self.init(cgImage: aCgImage)
    }
    
    /// Create a new image from a base 64 string
    convenience init?(base64String: String, scale: CGFloat = 1.0) {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        self.init(data: data, scale: scale)
    }

}

public extension XZ where Base: UIImage {
    
    /// UIImage Cropped to CGRect
    func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.width <= base.size.width && rect.size.height <= base.size.height else { return base }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: base.scale, y: base.scale))
        guard let image = base.cgImage?.cropping(to: scaledRect) else { return base }
        return UIImage(cgImage: image, scale: base.scale, orientation: base.imageOrientation)
    }
    
    /// UIImage scaled to height with respect to aspect ratio
    func scaled(toHeight: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toHeight / base.size.height
        let newWidth = base.size.width * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: toHeight), opaque, base.scale)
        base.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: toHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// UIImage scaled to width with respect to aspect ratio
    func scaled(toWidth: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toWidth / base.size.width
        let newHeight = base.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: toWidth, height: newHeight), opaque, base.scale)
        base.draw(in: CGRect(x: 0, y: 0, width: toWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Creates a copy of the receiver rotated by the given angle.
    ///
    ///     // Rotate the image by 180°
    ///     image.rotated(by: Measurement(value: 180, unit: .degrees))
    @available(iOS 10.0, tvOS 10.0, watchOS 3.0, *)
    func rotated(by angle: Measurement<UnitAngle>) -> UIImage? {
        let radians = CGFloat(angle.converted(to: .radians).value)
        
        let destRect = CGRect(origin: .zero, size: base.size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())
        
        UIGraphicsBeginImageContext(roundedDestRect.size)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }
        
        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)
        
        base.draw(in: CGRect(origin: CGPoint(x: -base.size.width / 2,
                                             y: -base.size.height / 2),
                        size: base.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Creates a copy of the receiver rotated by the given angle (in radians).
    ///
    ///     // Rotate the image by 180°
    ///     image.rotated(by: .pi)
    ///
    func rotated(by radians: CGFloat) -> UIImage? {
        let destRect = CGRect(origin: .zero, size: base.size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())
        
        UIGraphicsBeginImageContext(roundedDestRect.size)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }
        
        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)
        
        base.draw(in: CGRect(origin: CGPoint(x: -base.size.width / 2,
                                             y: -base.size.height / 2),
                             size: base.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// UIImage filled with color
    func filled(withColor color: UIColor) -> UIImage {
        
        #if !os(watchOS)
        if #available(iOS 10.0, tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = base.scale
            let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
            return renderer.image { context in
                color.setFill()
                context.fill(CGRect(origin: .zero, size: base.size))
            }
        }
        #endif
        
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext() else { return base }
        
        context.translateBy(x: 0, y: base.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height)
        guard let mask = base.cgImage else { return base }
        context.clip(to: rect, mask: mask)
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
//    func tint(_ color: UIColor) {
//        return tint(color, blendMode: <#T##CGBlendMode#>, alpha: <#T##CGFloat#>)
//    }
    
    /// UIImage tinted with color
    ///
    /// - Parameters:
    ///   - color: color to tint image with.
    ///   - blendMode: how to blend the tint
    /// - Returns: UIImage tinted with given color.
    func tint(_ color: UIColor, blendMode: CGBlendMode, alpha: CGFloat = 1.0) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: base.size)
        
        #if !os(watchOS)
        if #available(iOS 10.0, tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = base.scale
            return UIGraphicsImageRenderer(size: base.size, format: format).image { context in
                color.setFill()
                context.fill(drawRect)
                base.draw(in: drawRect, blendMode: blendMode, alpha: alpha)
            }
        }
        #endif
        
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(drawRect)
        base.draw(in: drawRect, blendMode: blendMode, alpha: alpha)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    /// UImage with background color
    ///
    /// - Parameters:
    ///   - backgroundColor: Color to use as background color
    /// - Returns: UIImage with a background color that is visible where alpha < 1
    func withBackgroundColor(_ backgroundColor: UIColor) -> UIImage {
        
        #if !os(watchOS)
        if #available(iOS 10.0, tvOS 10.0, *) {
            let format = UIGraphicsImageRendererFormat()
            format.scale = base.scale
            return UIGraphicsImageRenderer(size: base.size, format: format).image { context in
                backgroundColor.setFill()
                context.fill(context.format.bounds)
                base.draw(at: .zero)
            }
        }
        #endif
        
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        defer { UIGraphicsEndImageContext() }
        
        backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: base.size))
//        UIColor.white.setStroke()
//        CGContext.addEllipse(<#T##self: CGContext##CGContext#>)
        base.draw(at: .zero)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
    
    /// UIImage with rounded corners
    ///
    /// - Parameters:
    ///   - radius: corner radius (optional), resulting image will be round if unspecified
    /// - Returns: UIImage with all corners rounded
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(base.size.width, base.size.height) / 2
        let cornerRadius: CGFloat
        if let radius = radius, radius > 0 && radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }
        
        UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
        
        let rect = CGRect(origin: .zero, size: base.size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        base.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


// MARK: -
public extension XZ where Base: UIImage {
    
    class func resizableImage(color: UIColor, radius: CGFloat) -> UIImage? {
        let insets = UIEdgeInsets(top: radius+1, left: radius+1, bottom: radius+1, right: radius+1)
        
        if let img = UIImage(color: color, size: CGSize(width: radius*2+2, height: radius*2+2)).xz.withRoundedCorners(radius: radius) {
            let strechedimg = img.resizableImage(withCapInsets: insets, resizingMode: .stretch)
            return strechedimg
        }
        return nil
    }
}

// MARK: - Rotate
public extension XZ where Base: UIImage {
    
    func rotatedImage(originalImg: UIImage!, angle: CGFloat?) -> UIImage {
        if angle ?? 0 > 0 {
            let newAssetAngle = angle!.truncatingRemainder(dividingBy: CGFloat.pi*2)
            let rad = newAssetAngle/CGFloat.pi
            var ort = UIImage.Orientation.up
            switch rad {
            case 0.001...0.5:
                ort = UIImage.Orientation.right
            case 0.5...1:
                ort = UIImage.Orientation.down
            case 1...1.5:
                ort = UIImage.Orientation.left
            default:
                ort = UIImage.Orientation.up
            }
            
            if let cgImg = originalImg.cgImage {
                return UIImage(cgImage: cgImg, scale: originalImg.scale, orientation: ort)
            }
        }
        return originalImg
    }
}
