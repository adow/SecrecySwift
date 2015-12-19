//
//  AES.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/11.
//  Copyright © 2015年 秦 道平. All rights reserved.
//
//  key 满足 16(AES128)/24(AES192)/32(AES256) 位
//  只支持 ECB/CBC 模式， cbc 模式必须要 IV,只支持 PKCS7Padding
//  raw 的长度必须大于3个字符

import Foundation
import CommonCrypto


extension NSData {
    // MARK: cbc
    private func aesCBC(operation:CCOperation,key:String, iv:String? = nil) -> NSData? {
        guard [16,24,32].contains(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_bytes = [UInt8](count: input_bytes.count * 2, repeatedValue: 0)
        var encrypt_length = 0
        let iv_bytes = (iv != nil) ? UnsafePointer<UInt8>(iv!.bytes) : UnsafePointer<UInt8>(nil)
        let status = CCCrypt(UInt32(operation), UInt32(kCCAlgorithmAES128), UInt32(kCCOptionPKCS7Padding),
                key_bytes, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), iv_bytes,
                input_bytes, input_bytes.count, &encrypt_bytes, input_bytes.count * 2, &encrypt_length)
        if status == Int32(kCCSuccess) {
            return NSData(bytes: encrypt_bytes, length: encrypt_length)
        }
        return nil
    }
    /// Encrypt data in CBC Mode, iv will be filled with zero if not specificed
    public func aesCBCEncrypt(key:String,iv:String? = nil) -> NSData? {
        return aesCBC(UInt32(kCCEncrypt), key: key, iv: iv)
    }
    /// Decrypt data in CBC Mode ,iv will be filled with zero if not specificed
    public func aesCBCDecrypt(key:String,iv:String? = nil)->NSData?{
        return aesCBC(UInt32(kCCDecrypt), key: key, iv: iv)
    }
    // MARK: ecb
    private func aesEBC(operation:CCOperation, key:String) -> NSData? {
        guard [16,24,32].contains(key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_bytes = [UInt8](count: input_bytes.count * 2, repeatedValue: 0)
        var encrypt_length = 0
        let status = CCCrypt(UInt32(operation), UInt32(kCCAlgorithmAES128), UInt32(kCCOptionPKCS7Padding + kCCOptionECBMode),
            key_bytes, key.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), nil,
            input_bytes, input_bytes.count, &encrypt_bytes, input_bytes.count * 2, &encrypt_length)
        if status == Int32(kCCSuccess) {
            return NSData(bytes: encrypt_bytes, length: encrypt_length)
        }
        return nil
    }
    /// Encrypt data in EBC Mode
    public func aesEBCEncrypt(key:String) -> NSData? {
        return aesEBC(UInt32(kCCEncrypt), key: key)
        
    }
    /// Decrypt data in EBC Mode
    public func aesEBCDecrypt(key:String) -> NSData? {
        return aesEBC(UInt32(kCCDecrypt), key: key)
    }
}
extension String{
    // MARK: cbc
    /// Encrypt string in CBC mode, iv will be filled with Zero if not specificed
    public func aesCBCEncrypt(key:String,iv:String? = nil) -> NSData? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
//        print(data!.hexString)
        return data?.aesCBCEncrypt(key, iv: iv)
    }
    /// Decrypt a hexadecimal string in CBC Mode, iv will be filled with Zero if not specificed
    public func aesCBCDecryptFromHex(key:String,iv:String? = nil) ->String?{
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
//        print(raw_data.hexString)
        return String(data: raw_data, encoding: NSUTF8StringEncoding)
    }
    /// Decrypt a base64 string in CBC mode, iv will be filled with Zero if not specificed
    public func aesCBCDecryptFromBase64(key:String, iv:String? = nil) ->String? {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions())
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: NSUTF8StringEncoding)
    }
    // MARK: ebc
    /// Encrypt a string in EBC Mode
    public func aesEBCEncrypt(key:String) -> NSData? {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)
        return data?.aesEBCEncrypt(key)
    }
    /// Decrypt a hexadecimal string in EBC Mode
    public func aesEBCDecryptFromHex(key:String) -> String? {
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesEBCDecrypt(key) else {
            return nil
        }
        return String(data: raw_data, encoding: NSUTF8StringEncoding)
    }
    /// Decrypt a base64 string in EBC Mode
    public func aesEBCDecryptFromBase64(key:String) -> String? {
        let data = NSData(base64EncodedString: self, options: NSDataBase64DecodingOptions())
        guard let raw_data = data?.aesEBCDecrypt(key) else {
            return nil
        }
        return String(data: raw_data, encoding: NSUTF8StringEncoding)
    }
}