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

public typealias DigestAlgorithmClosure = (data: UnsafePointer<UInt8>, dataLength: UInt32) -> [UInt8]

public enum DigestAlgorithm: CustomStringConvertible {
    case MD2, MD4, MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func progressClosure() -> DigestAlgorithmClosure {
        var closure: DigestAlgorithmClosure?
        
        switch self {
        case .MD2:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_MD2($0, $1, &hash)
                
                return hash
            }
        case .MD4:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_MD4($0, $1, &hash)
                
                return hash
            }
        case .MD5:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_MD5($0, $1, &hash)
                
                return hash
            }
        case .SHA1:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_SHA1($0, $1, &hash)
                
                return hash
            }
        case .SHA224:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_SHA224($0, $1, &hash)
                
                return hash
            }
        case .SHA256:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_SHA256($0, $1, &hash)
                
                return hash
            }
        case .SHA384:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_SHA384($0, $1, &hash)
                
                return hash
            }
        case .SHA512:
            closure = {
                var hash = [UInt8](count: self.digestLength(), repeatedValue: 0)
                CC_SHA512($0, $1, &hash)
                
                return hash
            }
        }
        return closure!
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD2:
            result = CC_MD2_DIGEST_LENGTH
        case .MD4:
            result = CC_MD4_DIGEST_LENGTH
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
            case .MD2:
                return "Digest.MD2"
            case .MD4:
                return "Digest.MD4"
            case .MD5:
                return "Digest.MD5"
            case .SHA1:
                return "Digest.SHA1"
            case .SHA224:
                return "Digest.SHA224"
            case .SHA256:
                return "Digest.SHA256"
            case .SHA384:
                return "Digest.SHA384"
            case .SHA512:
                return "Digest.SHA512"
            }
        }
    }
}

extension String {
    public func digestBytes(algorithm:DigestAlgorithm)->[UInt8]{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.digestBytes(algorithm)
    }
    public func digestData(algorithm:DigestAlgorithm)->NSData{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.digestData(algorithm)
    }
    public func digestHex(algorithm:DigestAlgorithm)->String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.digestHex(algorithm)
    }
    public func digestBase64(algorithm:DigestAlgorithm)->String{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data!.digestBase64(algorithm)
    }
}

extension NSData {
    public func digestBytes(algorithm:DigestAlgorithm)->[UInt8]{
        let string = UnsafePointer<UInt8>(self.bytes)
        let stringLength = UInt32(self.length)
        
        let closure = algorithm.progressClosure()
        
        let bytes = closure(data: string, dataLength: stringLength)
        return bytes
    }
    public func digestData(algorithm:DigestAlgorithm)->NSData{
        let bytes = self.digestBytes(algorithm)
        return NSData(bytes: bytes, length: bytes.count)
    }
    public func digestHex(algorithm:DigestAlgorithm)->String{
        let digestLength = algorithm.digestLength()
        let bytes = self.digestBytes(algorithm)
        var hashString: String = ""
        for i in 0..<digestLength {
            hashString += String(format: "%02x", bytes[i])
        }
        return hashString
    }
    public func digestBase64(algorithm:DigestAlgorithm)->String{
        let data = self.digestData(algorithm)
        return data.base64String
    }
}