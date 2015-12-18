# SecrecySwift

使用 SecrecySwift 来完成 Swift 平台下的签名加密方法，可以实现: 摘要/AES/RSA加密和签名

## 摘要和 HMAC

* MD2；
* MD4；
* MD5；
* SHA1;
* SHA224；
* SHA256；
* SHA384；
* SHA512；

### 摘要方法:

NSData/String 的 `digestHex/digestBase64` 支持将摘要输出为 hex 和 base64 字符串;

		let raw = "abc123"
		print(raw.digestHex(DigestAlgorithm.MD5))
		print(raw.digestBase64(DigestAlgorithm.MD5))


### HMAC 签名方法

NSData/String 的 `signHex/signBase64` 方法支持签名输出为 hex 和 base64 字符串;

		let raw = "abc123"
		print(raw.signHex(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "你好"))


## AES 


支持 AES 模式 :

* EBC;
* CBC: 

只支持 PKCSPaddding7 的补齐方式；

根据提供的 Key 的长度，支持以下的加密方法

* AES128: 16位
* AES192: 24位;
* AES256: 32位;

只支持 EBC/CBC 模式的加密解密

### EBC 模式

* `aesEBCEncrypt` 进行EBC模式加密，
* `aesEBCDecryptFromHex` 从 hex 字符串进行EBC模式解密
* `aesEBCDecryptBase64` 从 base64 字符串进行EBC解密

		let key = "0000000000000000"
		let raw = "0123456789abcdef"
		let encrypt_1 = raw.aesEBCEncrypt(key)
		print(encrypt_1!.hexString)
		print(encrypt_1!.hexString.aesEBCDecryptFromHex(key))
		print(encrypt_1!.base64String)
		print(encrypt_1!.base64String.aesEBCDecryptFromBase64(key))

### CBC 模式  

CBC 模式可以指定 IV,如果不指定 IV 的话将用 0 填充;

* `aesCBCEncrypt` 进行加密;
* `aecCBCDecryptFromHex` 从 hex 字符串进行解密
* `aesCBCDecryptFromBase64` 从 base64 字符串进行解密
		
		let iv = "0000000000000000"
		let encrypt = raw.aesCBCEncrypt(key,iv: iv)
		print(encrypt!.hexString)
		print(encrypt!.hexString.aesCBCDecryptFromHex(key,iv: iv))
		print(encrypt!.base64String)
		print(encrypt!.base64String.aesCBCDecryptFromBase64(key,iv: iv))

## RSA 

只支持 `.cert` 文件格式的公钥和 `.p12` 格式的私钥；只支持 PKCS1Padding 的补齐；

使用 `OpenSSL` 生成各个证书的方法

	# 生成 RSA 私钥
	openssl genrsa  -out private.pem  2048
	
	# 从密钥中提取公钥
	openssl rsa  -pubout  -in private.pem  -out public.pem
	
	# 用私钥生成证书签名请求
	openssl req -new -key private.pem -out cert.csr
	
	# 用私钥和证书签名请求生成自签名的证书
	openssl x509 -req -days 3650 -in cert.csr -signkey private.pem -out cert.crt
	
	# 将自签名的证书转换为 DER 格式（里面包含公钥）
	openssl x509 -outform der -in cert.crt -out cert.der
	
	# 将私钥和证书导出到 p12 文件中（要求输入密码）
	openssl pkcs12 -export -inkey private.pem -in cert.crt -out cert.p12


### 加密和解密

使用公钥进行加密

* `public func encrypt(data:NSData) -> NSData?`

使用私钥进行解密 

* `public func decrypt(data:NSData) -> NSData?`
* `public func decrypt(fromHexString hexString:String) -> NSData?`
* `public func decrypt(fromBase64String base64String:String) -> NSData?`

		let path_public = NSBundle.mainBundle().pathForResource("cert", ofType: "der")!
		let path_private = NSBundle.mainBundle().pathForResource("cert", ofType: "p12")!
		let raw = "0123456789abcdefg"
		let raw_data = raw.dataUsingEncoding(NSUTF8StringEncoding)!
		let rsa = RSA(filenameOfPulbicKey: path_public, filenameOfPrivateKey: path_private)
		guard let _rsa = rsa else {
		    return
		}
		let encrypt_data = _rsa.encrypt(raw_data)
		let base64_string = encrypt_data!.base64String
		print(base64_string)
		let old_data = _rsa.decrypt(fromBase64String: base64_string)
		let old_string = String(data: old_data!, encoding: NSUTF8StringEncoding)
		print("old_string:\(old_string)")

### 签名和验证

支持签名时的摘要算法:
 
* MD2;
* MD5;
* SHA1;
* SHA224;
* SHA256;
* SHA384；
* SHA512；


使用私钥签名方法:

`public func sign(algorithm:RSAAlgorithm,inputData:NSData) -> NSData?`

使用公钥的验证方法:

`public func verify(algorithm:RSAAlgorithm,inputData:NSData, signedData:NSData) -> Bool`


		let path_public = NSBundle.mainBundle().pathForResource("cert", ofType: "der")!
		        let path_private = NSBundle.mainBundle().pathForResource("cert", ofType: "p12")!
		       
		let rsa = RSA(filenameOfPulbicKey: path_public, filenameOfPrivateKey: path_private)
		guard let _rsa = rsa else {
		    return
		}
		
		let raw = "0123456789abcdefg"
		let raw_data = raw.dataUsingEncoding(NSUTF8StringEncoding)!
		let sign_data = _rsa.sign(RSAAlgorithm.SHA1,inputData:raw_data)
		//        print(sign_data!.hexString)
		print(sign_data!.base64String)
		
		let raw_test = "0123456789abcdefg"
		let raw_test_data = raw_test.dataUsingEncoding(NSUTF8StringEncoding)!
		let verified = _rsa.verify(RSAAlgorithm.SHA1,inputData: raw_test_data, signedData: sign_data!)
		print("\(verified)")
		
## 扩展 NSData

* `hexString`: 输出 hex 字符串;
* `base64String`: 输出 base64 字符串
* `arrayOfBytes`: 输出 `[UInt8]` 数组;


		extension NSData {
			public var hexString : String
			public var base64String:String
			public func arrayOfBytes() -> [UInt8]
		}
		
## 扩展 String

* `dataFromHexadecimalString`: 从 hex 字符串转换到 NSData;

		extenstion String {
			func dataFromHexadecimalString() -> NSData?
		}
		
## References

* [【加密解密】加密解密介绍](http://www.jianshu.com/p/98610bdc9bd6)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [AES.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/AES.swift)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [RSA加密](http://blog.cnbluebox.com/blog/2014/03/19/rsajia-mi/)
* [RSA.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/RSA.swift)