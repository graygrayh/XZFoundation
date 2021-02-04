//
//  DataExt.swift
//  XZFoundation
//
//  Created by xzh on 2020/4/1.
//  Copyright © 2020 xzh. All rights reserved.
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif
import CommonCrypto

public extension Data {
    
    /// The MD5 hash of the data.
    var md5Hash: Data {
        
//        if #available(iOS 13.0, *) {
//            let digest = Insecure.MD5.hash(data: self)
//            return Data(digest)
//        } else {
            let len = Int(CC_MD5_DIGEST_LENGTH)
            let md = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: len)
            
            let _ = self.withUnsafeBytes {
                CC_MD5($0.baseAddress, numericCast($0.count), md)
            }
            return Data(bytes: md, count: len)
//        }
        
    }
    
    /// The MD5 has of the data, as a hexadecimal string.
    var md5String: String? {
        return md5Hash.hexadecimalString
    }
    
    /// A representation of the data as a hexadecimal string.
    ///
    /// Returns `nil` if the data is empty.
    var hexadecimalString: String? {
        if count == 0 {
            return nil
        }
        
        // Special case for MD5
        if count == 16 {
            return String(format: "%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", self[0], self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], self[9], self[10], self[11], self[12], self[13], self[14], self[15])
        }
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    /// Image signature constants.
    private enum ImageSignature {
        
        /// The signature for PNG data.
        ///
        /// [PNG signature](http://www.w3.org/TR/PNG/#5PNG-file-signature)\:
        /// The first eight bytes of a PNG datastream always contain the following (decimal) values:
        ///
        /// ```
        /// 137 80 78 71 13 10 26 10
        /// ```
        static let png = Data([137, 80, 78, 71, 13, 10, 26, 10])
        
        /// The signature for GIF 89a data.
        ///
        /// [http://www.onicos.com/staff/iz/formats/gif.html](http://www.onicos.com/staff/iz/formats/gif.html)
        static let gif89a = "GIF89a".data(using: .ascii)!
        
        /// The signature for GIF 87a data.
        ///
        /// [http://www.onicos.com/staff/iz/formats/gif.html](http://www.onicos.com/staff/iz/formats/gif.html)
        static let gif87a = "GIF87a".data(using: .ascii)!
        
        /// The signature for JPEG data.
        static let jpeg = Data([0xFF, 0xD8, 0xFF])
        
    }
    
    /// Check if data matches a signature at its start.
    ///
    /// - Parameter signatures: An array of signatures to match against.
    /// - Returns: `true` if the data matches; `false` otherwise.
    private func matchesSignature(from signatures: [Data]) -> Bool {
        for signature in signatures {
            if self.prefix(signature.count) == signature {
                return true
            }
        }
        
        return false
    }
    
    /// Returns `true` if the data begins with the PNG signature.
    var isPNG: Bool {
        return matchesSignature(from: [ImageSignature.png])
    }
    
    /// Returns `true` if the data begins with a valid GIF signature.
    var isGIF: Bool {
        return matchesSignature(from: [ImageSignature.gif89a, ImageSignature.gif87a])
    }
    
    /// Returns `true` if the data begins with a valid JPEG signature.
    var isJPEG: Bool {
        return matchesSignature(from: [ImageSignature.jpeg])
    }
    
    /// Returns `true` if the data is an image (PNG, JPEG, or GIF).
    var isImage: Bool {
        return  isPNG || isJPEG || isGIF
    }
    
}

extension Data: XZCompatible{}
public extension XZ where Base == Data{
    
    var etag: String?{
        // 块大小
        let blockSize: UInt64 = 4 * 1024 * 1024
        // 首字节标记位
        var prefix: UInt8 = 0x16
        var blockCount: UInt64 = 0
        let bufferSize: UInt64 = UInt64(self.base.count)
        blockCount = bufferSize / blockSize
        let remain: UInt64 = bufferSize % blockSize
        
        // 未整除，块总个数加1
        if remain > 0 {
            blockCount += 1
        }
        
        var sha1Data = Data()
        if blockCount > 1 {// 大于4M，头部拼接0x96单个字节
            prefix = 0x96
            for i in 0..<blockCount {
                var len = blockSize
                if i == blockCount-1 && remain > 0 {
                    len = remain
                }
                let start = i * blockSize
                let end = start + len
                //将每个块（包括4M块和小于4M的块）进行sha1加密并拼接起来
                let subData = base[start..<end].xz.hmacEncryption(algorithm: .SHA1)
                sha1Data.append(subData)
            }
            //将拼接块进行二次sha1加密
            sha1Data = sha1Data.xz.hmacEncryption(algorithm: .SHA1)
        }else{
            sha1Data = base.xz.hmacEncryption(algorithm: .SHA1)
        }
        
        if sha1Data.count > 0 {
            //将长度为21个字节的二进制数据进行url_safe_base64计算
            sha1Data.insert(prefix, at: 0)
            return sha1Data.xz.safeBase64
        }
        return nil
    }
    
    // 过滤特殊字符
    var safeBase64: String{
        var base64Str: String = self.base.base64EncodedString()
        base64Str = base64Str.replacingOccurrences(of: "+", with: "-")
        base64Str = base64Str.replacingOccurrences(of: "/", with: "_")
        base64Str = base64Str.replacingOccurrences(of: "=", with: "")
        return base64Str
    }
    
    // 加密
    func hmacEncryption(algorithm: CryptoAlgorithm, secretKey: String?=nil) -> Data{
        let selfData = self.base.withUnsafeBytes{$0}.bindMemory(to: UInt8.self).baseAddress!
        let selfLen = self.base.count
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
        return Data(bytes: result, count: digestLen)
    }
    
}
