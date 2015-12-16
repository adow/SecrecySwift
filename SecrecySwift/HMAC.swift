//
//  SHA.swift
//  SwiftSSL
//
//  Forked from: https://github.com/SwiftP2P/SwiftSSL/blob/master/SwiftSSL/HMAC.swift
//
//  Created by 0day on 14/10/6.
//  Copyright (c) 2014年 SwiftP2P. All rights reserved.
//

import Foundation
import CommonCrypto

// Base: http://stackoverflow.com/a/24411522/313633
public enum HMACAlgorithm: CustomStringConvertible {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:
            result = kCCHmacAlgMD5
        case .SHA1:
            result = kCCHmacAlgSHA1
        case .SHA224:
            result = kCCHmacAlgSHA224
        case .SHA256:
            result = kCCHmacAlgSHA256
        case .SHA384:
            result = kCCHmacAlgSHA384
        case .SHA512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:
            result = CC_MD5_DIGEST_LENGTH
        case .SHA1:
            result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:
            result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:
            result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:
            result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    public var description: String {
        get {
            switch self {
            case .MD5:
                return "HMAC.MD5"
            case .SHA1:
                return "HMAC.SHA1"
            case .SHA224:
                return "HMAC.SHA224"
            case .SHA256:
                return "HMAC.SHA256"
            case .SHA384:
                return "HMAC.SHA384"
            case .SHA512:
                return "HMAC.SHA512"
            }
        }
    }
}

extension String {
    public func signBytes(algorithm:HMACAlgorithm, key:String) -> [UInt8] {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.signBytes(algorithm, key: key)
    }
    public func signData(algorithm:HMACAlgorithm, key:String) -> NSData {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.signData(algorithm, key: key)
    }
    public func signHex(algorithm:HMACAlgorithm, key:String)->String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.signHex(algorithm, key: key)
    }
    public func signBase64(algorithm:HMACAlgorithm, key:String) -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.signBase64(algorithm, key: key)
    }
}

extension NSData {
    public func signBytes(algorithm:HMACAlgorithm, key:String) -> [UInt8]{
        let string = UnsafePointer<UInt8>(self.bytes)
        let stringLength = self.length
        let digestLength = algorithm.digestLength()
        let keyString = key.cStringUsingEncoding(NSUTF8StringEncoding)!
        let keyLength = key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var result = [UInt8](count: digestLength, repeatedValue: 0)
        CCHmac(algorithm.toCCEnum(), keyString, keyLength, string, stringLength, &result)
        return result
    }
    public func signData(algorithm:HMACAlgorithm, key:String) -> NSData {
        let bytes = self.signBytes(algorithm, key: key)
        let data = NSData(bytes: bytes, length: bytes.count)
        return data
    }
    public func signHex(algorithm:HMACAlgorithm, key:String)->String {
        let bytes = self.signBytes(algorithm, key: key)
        let digestLength = bytes.count
        var hash: String = ""
        for i in 0..<digestLength {
            hash += String(format: "%02x", bytes[i])
        }
        return hash
    }
    public func signBase64(algorithm:HMACAlgorithm, key:String) -> String {
        let data = self.signData(algorithm, key: key)
        return data.base64String
    }
    
}
