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
    case md5, sha1, sha224, sha256, sha384, sha512
    
    func toCCEnum() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .md5:
            result = kCCHmacAlgMD5
        case .sha1:
            result = kCCHmacAlgSHA1
        case .sha224:
            result = kCCHmacAlgSHA224
        case .sha256:
            result = kCCHmacAlgSHA256
        case .sha384:
            result = kCCHmacAlgSHA384
        case .sha512:
            result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .md5:
            result = CC_MD5_DIGEST_LENGTH
        case .sha1:
            result = CC_SHA1_DIGEST_LENGTH
        case .sha224:
            result = CC_SHA224_DIGEST_LENGTH
        case .sha256:
            result = CC_SHA256_DIGEST_LENGTH
        case .sha384:
            result = CC_SHA384_DIGEST_LENGTH
        case .sha512:
            result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    public var description: String {
        get {
            switch self {
            case .md5:
                return "HMAC.MD5"
            case .sha1:
                return "HMAC.SHA1"
            case .sha224:
                return "HMAC.SHA224"
            case .sha256:
                return "HMAC.SHA256"
            case .sha384:
                return "HMAC.SHA384"
            case .sha512:
                return "HMAC.SHA512"
            }
        }
    }
}

extension String {
    /// Sign to an array ot UInt8
    public func signBytes(_ algorithm:HMACAlgorithm, key:String) -> [UInt8] {
        let data = self.data(using: String.Encoding.utf8)
        return data!.signBytes(algorithm, key: key)
    }
    /// Sign with algorithm
    public func signData(_ algorithm:HMACAlgorithm, key:String) -> Data {
        let data = self.data(using: String.Encoding.utf8)
        return data!.signData(algorithm, key: key)
    }
    /// Sign and hexadecimal string will be returned
    public func signHex(_ algorithm:HMACAlgorithm, key:String)->String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.signHex(algorithm, key: key)
    }
    /// Sign and base64 string will be returned
    public func signBase64(_ algorithm:HMACAlgorithm, key:String) -> String {
        let data = self.data(using: String.Encoding.utf8)
        return data!.signBase64(algorithm, key: key)
    }
}

extension Data {
    /// Sign data to an array of UInt8
    public func signBytes(_ algorithm:HMACAlgorithm, key:String) -> [UInt8]{
        let string = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        let stringLength = self.count
        let digestLength = algorithm.digestLength()
        let keyString = key.cString(using: String.Encoding.utf8)!
        let keyLength = key.lengthOfBytes(using: String.Encoding.utf8)
        var result = [UInt8](repeating: 0, count: digestLength)
        CCHmac(algorithm.toCCEnum(), keyString, keyLength, string, stringLength, &result)
        return result
    }
    /// Sign with an algorithm
    public func signData(_ algorithm:HMACAlgorithm, key:String) -> Data {
        let bytes = self.signBytes(algorithm, key: key)
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        return data
    }
    /// Sign a data and export to a hexadecimal string
    public func signHex(_ algorithm:HMACAlgorithm, key:String)->String {
        let bytes = self.signBytes(algorithm, key: key)
        let digestLength = bytes.count
        var hash: String = ""
        for i in 0..<digestLength {
            hash += String(format: "%02x", bytes[i])
        }
        return hash
    }
    /// Sign a data and export to a base64 string
    public func signBase64(_ algorithm:HMACAlgorithm, key:String) -> String {
        let data = self.signData(algorithm, key: key)
        return data.base64String
    }
    
}
