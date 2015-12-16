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
    private func test_rsa(){
        let path_public = NSBundle.mainBundle().pathForResource("cert", ofType: "der")!
        let path_private = NSBundle.mainBundle().pathForResource("cert", ofType: "p12")!
        let raw = "0123456789abcdefg"
        let raw_data = raw.dataUsingEncoding(NSUTF8StringEncoding)!
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
        let old_string = String(data: old_data!, encoding: NSUTF8StringEncoding)
        print("old_string:\(old_string)")
        
    }
    private func test_rsa_signature(){
        let path_public = NSBundle.mainBundle().pathForResource("cert", ofType: "der")!
        let path_private = NSBundle.mainBundle().pathForResource("cert", ofType: "p12")!
       
        let rsa = RSA(filenameOfPulbicKey: path_public, filenameOfPrivateKey: path_private)
        guard let _rsa = rsa else {
            return
        }
        
        let raw = "0123456789abcdefg"
        let raw_data = raw.dataUsingEncoding(NSUTF8StringEncoding)!
        let sign_data = _rsa.sign(RSAAlgorithm.SHA1,inputData:raw_data)
        print(sign_data!.hexString)
       
        let raw_test = "0123456789abcdefg"
        let raw_test_data = raw_test.dataUsingEncoding(NSUTF8StringEncoding)!
        let verified = _rsa.verify(RSAAlgorithm.SHA1,inputData: raw_test_data, signedData: sign_data!)
        print("\(verified)")
    }
    
}
extension ViewController{
    private func test_aes(){
        let key = "0000000000000000"
//        let raw = "0123456789abcdef"
//        let raw = "123你好把呵呵"
        let raw = "你好!a"
        let encrypt_1 = raw.aesEBCEncrypt(key)
        print(encrypt_1!.hexString)
        print(encrypt_1!.hexString.aesEBCDecryptFromHex(key))
        print(encrypt_1!.base64String)
        print(encrypt_1!.base64String.aesEBCDecryptFromBase64(key))
        
//        let iv = "1111111111111111"
        let iv = "0000000000000000000000000000000000"
        let encrypt = raw.aesCBCEncrypt(key,iv: iv)
        print(encrypt!.hexString)
        print(encrypt!.hexString.aesCBCDecryptFromHex(key,iv: iv))
        print(encrypt!.base64String)
        print(encrypt!.base64String.aesCBCDecryptFromBase64(key,iv: iv))
    }
    private func test_digest_hmac(){
        let raw = "abc123"
        print(raw.digestHex(DigestAlgorithm.MD5))
        print(raw.digestBase64(DigestAlgorithm.MD5))
        print(raw.signHex(HMACAlgorithm.SHA1, key: "abc"))
        print(raw.signBase64(HMACAlgorithm.SHA1, key: "abc"))
        print(raw.signBase64(HMACAlgorithm.SHA1, key: "你好"))
        
    }
}

