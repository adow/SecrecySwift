//
//  RSA.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/15.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import Foundation
import Security
public enum RSAAlgorithm:Int {
    case SHA1 = 0, SHA224, SHA256, SHA384, SHA512, MD2, MD5
    public var padding:SecPadding {
        switch self {
        case .SHA1:
            return SecPadding.PKCS1SHA1
        case .SHA224:
            return SecPadding.PKCS1SHA224
        case .SHA256:
            return SecPadding.PKCS1SHA256
        case .SHA384:
            return SecPadding.PKCS1SHA384
        case .SHA512:
            return SecPadding.PKCS1SHA512
        case .MD2:
            return SecPadding.PKCS1MD2
        case .MD5:
            return SecPadding.PKCS1MD5
        }
    }
    public var digestAlgorithm:DigestAlgorithm {
        switch self {
        case .SHA1:
            return DigestAlgorithm.SHA1
        case .SHA224:
            return DigestAlgorithm.SHA224
        case .SHA256:
            return DigestAlgorithm.SHA256
        case .SHA384:
            return DigestAlgorithm.SHA384
        case .SHA512:
            return DigestAlgorithm.SHA512
        case .MD2:
            return DigestAlgorithm.MD2
        case .MD5:
            return DigestAlgorithm.MD5
        }
    }
}
// MARK: - func
/// encrypt
private func rsa_encrypt(inputData:NSData, withKey key:SecKeyRef) -> NSData?{
    guard inputData.length > 0 && inputData.length < SecKeyGetBlockSize(key) - 11  else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var encrypt_bytes = [UInt8](count: key_size, repeatedValue: 0)
    var output_size : Int = key_size
    if SecKeyEncrypt(key, SecPadding.PKCS1,
        inputData.arrayOfBytes(), inputData.length,
        &encrypt_bytes, &output_size) == errSecSuccess {
            return NSData(bytes: encrypt_bytes, length: output_size)
    }
    return nil
}
/// decrypt
private func rsa_decrypt(inputData:NSData, withKey key:SecKeyRef) -> NSData? {
    guard inputData.length == SecKeyGetBlockSize(key) else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var decrypt_bytes = [UInt8](count: key_size, repeatedValue: 0)
    var output_size: Int = key_size
    if SecKeyDecrypt(key, SecPadding.PKCS1, inputData.arrayOfBytes(), inputData.length, &decrypt_bytes, &output_size) == errSecSuccess {
        return NSData(bytes: decrypt_bytes, length: output_size)
    }
    else {
        return nil
    }
}
/// sign
private func rsa_sign(inputData:NSData,withAlgorithm algorithm:RSAAlgorithm, withKey key:SecKeyRef) -> NSData? {
    let digestInputData = inputData.digestData(algorithm.digestAlgorithm)
//    print("digestInput:\(digestInputData.hexString)")
    guard digestInputData.length > 0 && digestInputData.length < SecKeyGetBlockSize(key) - 11  else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var sign_bytes = [UInt8](count: key_size, repeatedValue: 0)
    var sign_size : Int = key_size
    let result = SecKeyRawSign(key, algorithm.padding, digestInputData.arrayOfBytes(), digestInputData.length, &sign_bytes, &sign_size)
//    print("result:\(result)")
    if result == errSecSuccess {
        return NSData(bytes: sign_bytes, length: sign_size)
    }
    return nil
}
/// verify
private func rsa_verify(inputData:NSData, signedData:NSData,
    withAlgorithm algorithm:RSAAlgorithm, whthKey key:SecKeyRef) -> Bool {
    let digestInputData = inputData.digestData(algorithm.digestAlgorithm)
//    print("digestInput:\(digestInputData.hexString)")   
    guard digestInputData.length > 0 && digestInputData.length < SecKeyGetBlockSize(key) - 11  else {
        return false
    }
    let result = SecKeyRawVerify(key, algorithm.padding, digestInputData.arrayOfBytes(), digestInputData.length, signedData.arrayOfBytes(), signedData.length)
    return result == errSecSuccess
}
/// publicKey
private func rsa_publickey_from_data(keyData:NSData) -> SecKeyRef?{
    if let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, keyData) {
        let policy = SecPolicyCreateBasicX509()
        var trust : SecTrustRef?
        if SecTrustCreateWithCertificates(certificate, policy, &trust) == errSecSuccess {
            var trustResultType : SecTrustResultType = SecTrustResultType.Invalid
            if SecTrustEvaluate(trust!, &trustResultType) == errSecSuccess {
                return SecTrustCopyPublicKey(trust!)
            }
        }
        
    }
    return nil
    
}
/// privateKey
private func rsa_privatekey_from_data(keyData:NSData, withPassword password:String) -> SecKeyRef? {
    var privateKey: SecKeyRef? = nil
    let options : [String:String] = [kSecImportExportPassphrase as String:password]
    var items : CFArray?
    if SecPKCS12Import(keyData, options, &items) == errSecSuccess {
        //            print("items:\(CFArrayGetCount(items))")
        if CFArrayGetCount(items) > 0 {
            let d = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),CFDictionaryRef.self)
            let k = unsafeAddressOf(kSecImportItemIdentity as NSString)
            let v = CFDictionaryGetValue(d, k)
            //                print("identity:\(identity)")
            let secIdentity = unsafeBitCast(v, SecIdentityRef.self)
            //                print("secIdentity:\(secIdentity)")
            if SecIdentityCopyPrivateKey(secIdentity, &privateKey) == errSecSuccess {
                return privateKey
            }
        }
    }
    
    return nil
}

// MARK: - RSA
public struct RSA {
    private let publicKey:SecKeyRef!
    private let privateKey:SecKeyRef!
    // MARK: init
    /// PublicKey must be in .der format and private must be in .p12 format
    public init(publicKey:SecKeyRef!, privateKey:SecKeyRef!){
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    public init(dataOfPublicKey publicKeyData:NSData,
        dataOfPrivateKey privateKeyData:NSData,
        withPasswordOfPrivateKey password:String = ""){
        self.publicKey = rsa_publickey_from_data(publicKeyData)!
        self.privateKey = rsa_privatekey_from_data(privateKeyData, withPassword: password)!
    }
    /* Generate RSA instance from file of public key and private key
        - parameter publicKeyFilename: filename of publicKey
        - parameter privateKeyFilename: filename of privateKey
        - parameter password: password or empty if not set
        - returns: RSA instance if succeed or nil if failed
    */
    public init?(filenameOfPulbicKey publicKeyFilename:String,
        filenameOfPrivateKey privateKeyFilename:String, withPasswordOfPrivateKey password:String = ""){
        let publicKeyData = NSData(contentsOfFile: publicKeyFilename)
        let privateKeyData = NSData(contentsOfFile: privateKeyFilename)
        guard let _publicKeyData = publicKeyData, _privateKeyData = privateKeyData else {
            return nil
        }
        self.publicKey = rsa_publickey_from_data(_publicKeyData)
        self.privateKey = rsa_privatekey_from_data(_privateKeyData, withPassword: password)!
    }
}
// MARK: - encrypt
extension RSA {
    /// Encrypt with privateKey
    public func encrypt(data:NSData) -> NSData? {
        return rsa_encrypt(data, withKey: self.publicKey)
    }
    /// Decrypt with publicKey
    public func decrypt(data:NSData) -> NSData? {
        return rsa_decrypt(data, withKey: self.privateKey)
    }
    /// Decrypt a hexadecimal string with publicKey
    public func decrypt(fromHexString hexString:String) -> NSData? {
        let data = hexString.dataFromHexadecimalString()
        guard let _data = data else {
            return nil
        }
        return self.decrypt(_data)
    }
    /// Decrypt a base64 string with publicKey
    public func decrypt(fromBase64String base64String:String) -> NSData? {
        let data = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions())
        guard let _data = data else {
            return nil
        }
        return self.decrypt(_data)
    }
}
// MARK: - sign
extension RSA {
    /// Sign data with digest algorithm
    public func sign(algorithm:RSAAlgorithm,inputData:NSData) -> NSData? {
        return rsa_sign(inputData, withAlgorithm: algorithm, withKey: self.privateKey)
    }
    /// Verify signature with algorithm
    public func verify(algorithm:RSAAlgorithm,inputData:NSData, signedData:NSData) -> Bool {
        return rsa_verify(inputData, signedData: signedData, withAlgorithm: algorithm, whthKey: self.publicKey)
    }
}
