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
    case sha1 = 0, sha224, sha256, sha384, sha512, md2, md5
    public var padding:SecPadding {
        switch self {
        case .sha1:
            return SecPadding.PKCS1SHA1
        case .sha224:
            return SecPadding.PKCS1SHA224
        case .sha256:
            return SecPadding.PKCS1SHA256
        case .sha384:
            return SecPadding.PKCS1SHA384
        case .sha512:
            return SecPadding.PKCS1SHA512
        case .md2:
            return SecPadding.PKCS1MD2
        case .md5:
            return SecPadding.PKCS1MD5
        }
    }
    public var digestAlgorithm:DigestAlgorithm {
        switch self {
        case .sha1:
            return DigestAlgorithm.sha1
        case .sha224:
            return DigestAlgorithm.sha224
        case .sha256:
            return DigestAlgorithm.sha256
        case .sha384:
            return DigestAlgorithm.sha384
        case .sha512:
            return DigestAlgorithm.sha512
        case .md2:
            return DigestAlgorithm.md2
        case .md5:
            return DigestAlgorithm.md5
        }
    }
}
// MARK: - func
/// encrypt
private func rsa_encrypt(_ inputData:Data, withKey key:SecKey) -> Data?{
    guard inputData.count > 0 && inputData.count < SecKeyGetBlockSize(key) - 11  else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var encrypt_bytes = [UInt8](repeating: 0, count: key_size)
    var output_size : Int = key_size
    if SecKeyEncrypt(key, SecPadding.PKCS1,
        inputData.arrayOfBytes(), inputData.count,
        &encrypt_bytes, &output_size) == errSecSuccess {
            return Data(bytes: UnsafePointer<UInt8>(encrypt_bytes), count: output_size)
    }
    return nil
}
/// decrypt
private func rsa_decrypt(_ inputData:Data, withKey key:SecKey) -> Data? {
    guard inputData.count == SecKeyGetBlockSize(key) else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var decrypt_bytes = [UInt8](repeating: 0, count: key_size)
    var output_size: Int = key_size
    if SecKeyDecrypt(key, SecPadding.PKCS1, inputData.arrayOfBytes(), inputData.count, &decrypt_bytes, &output_size) == errSecSuccess {
        return Data(bytes: UnsafePointer<UInt8>(decrypt_bytes), count: output_size)
    }
    else {
        return nil
    }
}
/// sign
private func rsa_sign(_ inputData:Data,withAlgorithm algorithm:RSAAlgorithm, withKey key:SecKey) -> Data? {
    let digestInputData = inputData.digestData(algorithm.digestAlgorithm)
//    print("digestInput:\(digestInputData.hexString)")
    guard digestInputData.count > 0 && digestInputData.count < SecKeyGetBlockSize(key) - 11  else {
        return nil
    }
    let key_size = SecKeyGetBlockSize(key)
    var sign_bytes = [UInt8](repeating: 0, count: key_size)
    var sign_size : Int = key_size
    let result = SecKeyRawSign(key, algorithm.padding, digestInputData.arrayOfBytes(), digestInputData.count, &sign_bytes, &sign_size)
//    print("result:\(result)")
    if result == errSecSuccess {
        return Data(bytes: UnsafePointer<UInt8>(sign_bytes), count: sign_size)
    }
    return nil
}
/// verify
private func rsa_verify(_ inputData:Data, signedData:Data,
    withAlgorithm algorithm:RSAAlgorithm, whthKey key:SecKey) -> Bool {
    let digestInputData = inputData.digestData(algorithm.digestAlgorithm)
//    print("digestInput:\(digestInputData.hexString)")   
    guard digestInputData.count > 0 && digestInputData.count < SecKeyGetBlockSize(key) - 11  else {
        return false
    }
    let result = SecKeyRawVerify(key, algorithm.padding, digestInputData.arrayOfBytes(), digestInputData.count, signedData.arrayOfBytes(), signedData.count)
    return result == errSecSuccess
}
/// publicKey
private func rsa_publickey_from_data(_ keyData:Data) -> SecKey?{
    if let certificate = SecCertificateCreateWithData(kCFAllocatorDefault, keyData as CFData) {
        let policy = SecPolicyCreateBasicX509()
        var trust : SecTrust?
        if SecTrustCreateWithCertificates(certificate, policy, &trust) == errSecSuccess {
            var trustResultType : SecTrustResultType = SecTrustResultType.invalid
            if SecTrustEvaluate(trust!, &trustResultType) == errSecSuccess {
                return SecTrustCopyPublicKey(trust!)
            }
        }
        
    }
    return nil
    
}
/// privateKey
private func rsa_privatekey_from_data(_ keyData:Data, withPassword password:String) -> SecKey? {
    var privateKey: SecKey? = nil
    let options : [String:String] = [kSecImportExportPassphrase as String:password]
    var items : CFArray?
    if SecPKCS12Import(keyData as CFData, options as CFDictionary, &items) == errSecSuccess {
        //            print("items:\(CFArrayGetCount(items))")
        if CFArrayGetCount(items) > 0 {
            let d = unsafeBitCast(CFArrayGetValueAtIndex(items, 0),to: CFDictionary.self)
            let k = Unmanaged.passUnretained(kSecImportItemIdentity as NSString).toOpaque()
            let v = CFDictionaryGetValue(d, k)
            //                print("identity:\(identity)")
            let secIdentity = unsafeBitCast(v, to: SecIdentity.self)
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
    fileprivate let publicKey:SecKey!
    fileprivate let privateKey:SecKey!
    // MARK: init
    /// PublicKey must be in .der format and private must be in .p12 format
    public init(publicKey:SecKey!, privateKey:SecKey!){
        self.publicKey = publicKey
        self.privateKey = privateKey
    }
    public init(dataOfPublicKey publicKeyData:Data,
        dataOfPrivateKey privateKeyData:Data,
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
        let publicKeyData = try? Data(contentsOf: URL(fileURLWithPath: publicKeyFilename))
        let privateKeyData = try? Data(contentsOf: URL(fileURLWithPath: privateKeyFilename))
        guard let _publicKeyData = publicKeyData, let _privateKeyData = privateKeyData else {
            return nil
        }
        self.publicKey = rsa_publickey_from_data(_publicKeyData)
        self.privateKey = rsa_privatekey_from_data(_privateKeyData, withPassword: password)!
    }
}
// MARK: - encrypt
extension RSA {
    /// Encrypt with privateKey
    public func encrypt(_ data:Data) -> Data? {
        return rsa_encrypt(data, withKey: self.publicKey)
    }
    /// Decrypt with publicKey
    public func decrypt(_ data:Data) -> Data? {
        return rsa_decrypt(data, withKey: self.privateKey)
    }
    /// Decrypt a hexadecimal string with publicKey
    public func decrypt(fromHexString hexString:String) -> Data? {
        let data = hexString.dataFromHexadecimalString()
        guard let _data = data else {
            return nil
        }
        return self.decrypt(_data as Data)
    }
    /// Decrypt a base64 string with publicKey
    public func decrypt(fromBase64String base64String:String) -> Data? {
        let data = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions())
        guard let _data = data else {
            return nil
        }
        return self.decrypt(_data)
    }
}
// MARK: - sign
extension RSA {
    /// Sign data with digest algorithm
    public func sign(_ algorithm:RSAAlgorithm,inputData:Data) -> Data? {
        return rsa_sign(inputData, withAlgorithm: algorithm, withKey: self.privateKey)
    }
    /// Verify signature with algorithm
    public func verify(_ algorithm:RSAAlgorithm,inputData:Data, signedData:Data) -> Bool {
        return rsa_verify(inputData, signedData: signedData, withAlgorithm: algorithm, whthKey: self.publicKey)
    }
}
