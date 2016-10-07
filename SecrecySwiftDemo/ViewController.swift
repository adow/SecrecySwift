//
//  ViewController.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/10.
//  Copyright © 2015年 秦 道平. All rights reserved.
//

import UIKit
import Secrecy

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test_aes()
        test_rsa()
        test_rsa_signature()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController {
    fileprivate func test_rsa(){
        let path_public = Bundle.main.path(forResource: "cert", ofType: "der")!
        let path_private = Bundle.main.path(forResource: "cert", ofType: "p12")!
        let raw = "0123456789abcdefg"
        let raw_data = raw.data(using: String.Encoding.utf8)!
        let rsa = RSA(filenameOfPulbicKey: path_public, filenameOfPrivateKey: path_private)
        guard let _rsa = rsa else {
            return
        }
        let encrypt_data = _rsa.encrypt(raw_data)
//        let hex_string = encrypt_data!.hexString
//        print(hex_string)
//        let old_data = _rsa.decrypt(fromHexString: hex_string)
        let base64_string = encrypt_data!.base64String
        print(base64_string)
        let old_data = _rsa.decrypt(fromBase64String: base64_string)
        let old_string = String(data: old_data!, encoding: String.Encoding.utf8)
        print("old_string:\(old_string)")
        
    }
    fileprivate func test_rsa_signature(){
        let path_public = Bundle.main.path(forResource: "cert", ofType: "der")!
        let path_private = Bundle.main.path(forResource: "cert", ofType: "p12")!
       
        let rsa = RSA(filenameOfPulbicKey: path_public, filenameOfPrivateKey: path_private)
        guard let _rsa = rsa else {
            return
        }
        
        let raw = "0123456789abcdefg"
        print(raw.digestBase64(DigestAlgorithm.sha1))
        let raw_data = raw.data(using: String.Encoding.utf8)!
        let sign_data = _rsa.sign(RSAAlgorithm.sha1,inputData:raw_data)
//        print(sign_data!.hexString)
        print(sign_data!.base64String)
       
        let raw_test = "0123456789abcdefg"
        let raw_test_data = raw_test.data(using: String.Encoding.utf8)!
        let verified = _rsa.verify(RSAAlgorithm.sha1,inputData: raw_test_data, signedData: sign_data!)
        print("\(verified)")
    }
    
}
extension ViewController{
    fileprivate func test_aes(){
        let key = "0000000000000000"
        let raw = "0123456789abcdef"
//        let raw = "012345678"
//        let raw = "123你好把呵呵"
//        let raw = "你好!a"
        let encrypt_1 = raw.aesEBCEncrypt(key)
        print("aes encrypt hexString:\(encrypt_1!.hexString)")
        print("aes decrypt from hexString: \(encrypt_1!.hexString.aesEBCDecryptFromHex(key))")
        print("aes encrypt base64String: \(encrypt_1!.base64String)")
        print("aes decrypt from base64String: \(encrypt_1!.base64String.aesEBCDecryptFromBase64(key))")
        
//        let iv = "1111111111111111"
        let iv = "0000000000000000"
        let encrypt = raw.aesCBCEncrypt(key,iv: iv)
        print("aes encrypt hexString:\(encrypt!.hexString)")
        print("aes decrypt from hexString:\(encrypt!.hexString.aesCBCDecryptFromHex(key,iv: iv))")
        print("aes encrypt base64String:\(encrypt!.base64String)")
        print("aes decrypt from base64String:\(encrypt!.base64String.aesCBCDecryptFromBase64(key,iv: iv))")
    }
    fileprivate func test_digest_hmac(){
        let raw = "abc123"
        print(raw.digestHex(DigestAlgorithm.md5))
        print(raw.digestBase64(DigestAlgorithm.md5))
        print(raw.signHex(HMACAlgorithm.sha1, key: "abc"))
        print(raw.signBase64(HMACAlgorithm.sha1, key: "abc"))
        print(raw.signBase64(HMACAlgorithm.sha1, key: "你好"))
        
    }
}

