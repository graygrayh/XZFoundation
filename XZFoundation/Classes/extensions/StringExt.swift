//
//  StringExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/1.
//  Copyright © 2020 xzh. All rights reserved.
//

import UIKit
import CommonCrypto

// MARK:-字体、宽、高、行数、截取计算
public extension XZ where Base == String {
    
    func sizeWithFont(_ font: UIFont, maxSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat(Float.greatestFiniteMagnitude))) -> CGSize {
        let attrs = [NSAttributedString.Key.font: font]
        let rect = base.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: attrs, context: nil)
        return rect.size
    }
    
//    - (CGSize)sizeWithFont:(UIFont *)font andMaxSize:(CGSize)size {
//    //特殊的格式要求都写在属性字典中
//    NSDictionary *attrs = @{NSFontAttributeName: font};
//    //返回一个矩形，大小等于文本绘制完占据的宽和高。
//    return [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs   context:nil].size;
//    }
    
    ///height if fully rendered
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = base.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = base.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    /// Return the estimated number of lines with specified bounding width and font.
    func numberOfLines(withWidth width: CGFloat, font: UIFont) -> Int {
        let h = height(withConstrainedWidth: width, font: font)
        let lineHeight = font.lineHeight
        return Int(ceil(Double(h / lineHeight)))
    }
    
    /// 根据原字符串和长度裁剪和拼接字符串
    func fetchSubString(originString: String, maxLength: Int) -> String {
        var subString = originString
        if subString.count > maxLength {
            subString = String(subString.prefix(maxLength))
            subString = subString.appending("...")
        }
        return subString
    }
    
}

// MARK:-富文本、html
public extension XZ where Base == String {
    func html2Attributed(
        family: String = "-apple-system, BlinkMacSystemFont, sans-serif",
        weight: String = "normal",
        size: CGFloat,
        color: UIColor
    ) -> NSAttributedString? {
        let htmlCSSString = """
        <style>
        html * {
        font-size: \(size)px;
        color: #\(color.xz.hexString ?? UIColor.black.xz.hexString!);
        font-family: \(family);
        font-weight: \(weight);
        }
        </style>
        \(self)
        """
        
        guard let data = htmlCSSString.data(using: String.Encoding.utf8) else { return nil }
        
        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil)
    }
}

// MARK: - OffsetIndexableCollection
extension String: OffsetIndexableCollection {}
extension Substring: OffsetIndexableCollection{}
extension String.UTF8View: OffsetIndexableCollection{}
extension String.UTF16View: OffsetIndexableCollection{}
extension String.UnicodeScalarView: OffsetIndexableCollection{}

public enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
 
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String: XZCompatible{}
public extension XZ where Base == String{
    
    // MARK:- 编码、加密
    func hmacEncryption(algorithm: CryptoAlgorithm, secretKey: String?=nil, base64: Bool=true) -> String{
        let selfData = self.base.cString(using: .utf8)!
        let selfLen = self.base.lengthOfBytes(using: .utf8)
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        if let secret = secretKey {
            let secretData = secret.cString(using: .utf8)!
            let secretLen = secret.lengthOfBytes(using: .utf8)
            CCHmac(algorithm.HMACAlgorithm, secretData, secretLen, selfData, selfLen, result)
        }else{
            switch algorithm {
            case .MD5:
                CC_MD5(selfData, CC_LONG(selfLen), result)
            case .SHA1:
                CC_SHA1(selfData, CC_LONG(selfLen), result)
            case .SHA224:
                CC_SHA224(selfData, CC_LONG(selfLen), result)
            case .SHA256:
                CC_SHA256(selfData, CC_LONG(selfLen), result)
            case .SHA384:
                CC_SHA384(selfData, CC_LONG(selfLen), result)
            case .SHA512:
                CC_SHA512(selfData, CC_LONG(selfLen), result)
            }
        }
        
        if base64 {
            let resultData = Data(bytes: result, count: digestLen)
            return resultData.base64EncodedString()
        }else{
            return Self.stringFromBytes(bytes: result, length: digestLen)
        }
    }
    
    static func stringFromBytes(bytes: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String{
        var outputStr = String()
        for i in 0..<length {
            outputStr = outputStr.appendingFormat("%02x", bytes[i])
        }
        bytes.deallocate()
        return outputStr
    }
    
    var md5: String? {
        let data = base.data(using: .utf8)
        return data?.md5String
    }
    
    // md5随机字符串
    static var randomMD5: String?{
        let identifier = CFUUIDCreate(nil)
        let identifierString = CFUUIDCreateString(nil, identifier) as String
        if let cStr = identifierString.cString(using: .utf8){
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(cStr, CC_LONG(strlen(cStr)), &digest)
            var output = String()
            for i in digest {
                output = output.appendingFormat("%02X", i)
            }
            return output
        }
        return nil
    }
    
    ///base64编码
    var toBase64: String? {
        if let data = base.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    ///base64解码
    var fromBase64: String? {
        if let data = Data(base64Encoded: base) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // MARK:-字符串日期
    // 字符串转日期
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date?{
        let dateformatter = XZDateFormatterUtil.shared[format]
        dateformatter.dateFormat = format
        return dateformatter.date(from: base)
    }
    
    // 日期字符串转另一种格式日期字符串
    func convertDateString(inputFormat: String, outputFormat: String) -> String?{
        if let date = toDate(format: inputFormat){
            let dateformatter = XZDateFormatterUtil.shared[outputFormat]
            dateformatter.dateFormat = outputFormat
            return dateformatter.string(from: date)
        }
        return nil
    }
    
}

// MARK:-正则匹配、替换、url、分割、截取
public extension XZ where Base == String{
    func regexMatched(regex: String) -> [String]? {
        do {
            let regex: NSRegularExpression = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: base, options: [], range: NSMakeRange(0, base.count))
            
            var data = [String]()
            for item in matches {
                let string = (base as NSString).substring(with: item.range)
                data.append(string)
            }
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func regexGroups(pattern: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: base,
                                        range: NSRange(base.startIndex..., in: base))
            return matches.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: base) else {
                        return ""
                    }
                    return String(base[range])
                }
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    ///字符串替换
    func regexReplaceAll(regex: String, content: String) -> String {
        do {
            let re = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let modified = re.stringByReplacingMatches(in: base, options: .reportProgress, range: NSRange(location: 0, length: base.count), withTemplate: content)
            return modified
        } catch {
            print(error.localizedDescription)
            return base
        }
    }
    
    func regexReplaceFirst(regex: String, content: String) -> String {
        do {
            let re = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let nsrange = NSRange(base.startIndex..., in: base)
            let firstRange = re.rangeOfFirstMatch(in: base, options: [], range: nsrange)
            let modified = re.stringByReplacingMatches(in: base, options: [], range: firstRange, withTemplate: content)
            return modified
        } catch {
            print(error.localizedDescription)
            return base
        }
    }
    
    var isValidUrl: Bool {
        guard let _ = URL(string: base) else {
            return false
        }
        return true
    }
    
    var url: URL? {
        return URL(string: base)
    }
    
    // MARK:-字符分割、转换、截取、拼接
    func lastComponent(by char: Character) -> String?{
        if let lastIndex = base.i_lastIndex(of: char) {
            let subStr = base.i_suffix(from: lastIndex + 1)
            return String(subStr)
        }
        return nil
    }

    
    // 字符串转字符数组
    var chars: [Character]{
        var chars: [Character] = [Character]()
        for (_, value) in base.enumerated() {
            chars.append(value)
        }
        return chars
    }
    
    // MARK:-字节截取
    // 编码字节数
    func byteCount(encoding: Base.Encoding? = nil) -> Int{
        var enc = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
        if let tempEnc = encoding { enc = tempEnc }
        if let strBytes = base.data(using: enc){
            return strBytes.count
        }
        return -1
    }
    
    ///
    /// 字节数截取字符串，添加后缀
    ///
    /// - Parameter maxLen:最大字节数
    /// - Parameter encoding:字符编码方式
    /// - Parameter suffix:添加后缀
    /// - Returns:新字符串
    func byteLimitString(maxLen: Int, encoding: Base.Encoding? = nil, suffix: String? = nil) -> String{
        var enc = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
        if let tempEnc = encoding { enc = tempEnc }
        if let strData = base.data(using: enc), strData.count > maxLen {
            if let resultStr =  String(data: strData[0...maxLen], encoding: enc){
                return resultStr + (suffix ?? "")
            }
        }
        return base
    }
    
    // 字符截取，添加后缀
    func characterLimit(maxLen: Int=6, fromTail: Bool=false, suffix: String="...") -> String{
        if base.count <= maxLen {
            return base
        }else{
            var targetStr = fromTail ? String(base.suffix(maxLen)) : String(base.prefix(maxLen))
            if suffix.isEmpty {
                return targetStr
            }else{
                return targetStr.appending(suffix)
            }
        }
    }
    
}

// MARK: -trimed、path、localized等
public extension XZ where Base == String{
    var localized: String {
        return NSLocalizedString(base, comment: "")
    }
    
    var trimed: String {
        return base.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var expandingTildeInPath: String {
        return NSString(string: base).expandingTildeInPath
    }
    
    var isLocalFilePath: Bool {
        let fullpath = NSString(string: base).expandingTildeInPath
        return fullpath.hasPrefix("/") || fullpath.hasPrefix("file:/")
    }
}

// MARK: -字符串转对象
public extension XZ where Base == String{
    
    var toDict: [String: Any]? {
        guard let data = base.data(using: String.Encoding.utf8) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
            return nil
        }
        return dict
    }
    
}

