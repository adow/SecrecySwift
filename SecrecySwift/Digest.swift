//
//  SHA.swift
//  SwiftSSL
//  
//  Forked from: https://github.com/SwiftP2P/SwiftSSL/blob/master/SwiftSSL/Digest.swift
//
//  Created by 0day on 14/10/7.
//  Copyright (c) 2014年 SwiftP2P. All rights reserved.
//


import Foundation
import CommonCrypto

public typealias DigestAlgorithmClosure = (_ data: UnsafePointer<UInt8>, _ dataLength: UInt32) -> [UInt8]

public enum DigestAlgorithm: CustomStringConvertible {
    case md2, md4, md5, sha1, sha224, sha256, sha384, sha512
    
    func progressClosure() -> DigestAlgorithmClosure {
        var closure: DigestAlgorithmClosure?
        
        switch self {
        case .md2:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD2($0, $1, &hash)
                
                return hash
            }
        case .md4:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD4($0, $1, &hash)
                
                return hash
            }
        case .md5:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_MD5($0, $1, &hash)
                
                return hash
            }
        case .sha1:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA1($0, $1, &hash)
                
                return hash
            }
        case .sha224:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA224($0, $1, &hash)
                
                return hash
            }
        case .sha256:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA256($0, $1, &hash)
                
                return hash
            }
        case .sha384:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA384($0, $1, &hash)
                
                return hash
            }
        case .sha512:
            closure = {
                var hash = [UInt8](repeating: 0, count: self.digestLength())
                CC_SHA512($0, $1, &hash)
                
                return hash
            }
        }
        return closure!
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .md2:
            result = CC_MD2_DIGEST_LENGTH
        case .md4:
            result = CC_MD4_DIGEST_LENGTH
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
            case .md2:
                return "Digest.MD2"
            case .md4:
                return "Digest.MD4"
            case .md5:
                return "Digest.MD5"
            case .sha1:
                return "Digest.SHA1"
            case .sha224:
                return "Digest.SHA224"
            case .sha256:
                return "Digest.SHA256"
            case .sha384:
                return "Digest.SHA384"
            case .sha512:
                return "Digest.SHA512"
            }
        }
    }
}

extension String {
    /// Digest to an array of UInt8
    public func digestBytes(_ algorithm:DigestAlgorithm)->[UInt8]{
        let data = self.data(using: String.Encoding.utf8)
        return data!.digestBytes(algorithm)
    }
    /// Digest with an algorithm
    public func digestData(_ algorithm:DigestAlgorithm)->Data{
        let data = self.data(using: String.Encoding.utf8)
        return data!.digestData(algorithm)
    }
    /// Digest with an algorithm to a hexadecimal string
    public func digestHex(_ algorithm:DigestAlgorithm)->String{
        let data = self.data(using: String.Encoding.utf8)
        return data!.digestHex(algorithm)
    }
    /// Digest with an algorithm to a base64 string
    public func digestBase64(_ algorithm:DigestAlgorithm)->String{
        let data = self.data(using: String.Encoding.utf8)
        return data!.digestBase64(algorithm)
    }
}

extension Data {
    /// Digest data to an array of UInt8
    public func digestBytes(_ algorithm:DigestAlgorithm)->[UInt8]{
        let string = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        let stringLength = UInt32(self.count)
        
        let closure = algorithm.progressClosure()
        
        let bytes = closure(string, stringLength)
        return bytes
    }
    /// Digest data with an algorithm
    public func digestData(_ algorithm:DigestAlgorithm)->Data{
        let bytes = self.digestBytes(algorithm)
        return Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
    /// Digest data with an algorithm to a hexadecimal string
    public func digestHex(_ algorithm:DigestAlgorithm)->String{
        let digestLength = algorithm.digestLength()
        let bytes = self.digestBytes(algorithm)
        var hashString: String = ""
        for i in 0..<digestLength {
            hashString += String(format: "%02x", bytes[i])
        }
        return hashString
    }
    /// Digest string to a base64 string with an algorithm
    public func digestBase64(_ algorithm:DigestAlgorithm)->String{
        let data = self.digestData(algorithm)
        return data.base64String
    }
}
