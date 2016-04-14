# SecrecySwift

[Readme in English](README-en.md)

SecrecySwift ，通过包装 `CommonCrypto` 和 `Security.framework`,实现 Swift 下的摘要方法/AES/RSA加密和签名。

## 特性

* 摘要算法 (Digest/HMAC): `MD2`/`MD4`/`MD5`/`SHA1`/`SHA224`/`SHA384`/`SHA512`；
* AES 加密和解密: `EBC`/`CBC` 模式；
* RSA 加密/解密以及签名和验证算法: `MD2`/`MD5`/`SHA1`/`SHA224`/`SHA384`；

## 安装

### 使用 Carthage 安装

`Carthage` 是一个去中心化的包管理工具。

安装 Carthage

	$ brew update
	$ brew install carthage
	
集成 SecrecySwift 到 iOS 项目

1. 在项目中创建 `Cartfile` 文件，并添加下面内容

		git "https://github.com/adow/SecrecySwift.git" >= 0.3.3
		
2. 运行 `Carthage update`, 获取 SecrecySwift;
3. 拖动 `Carthage/Build/iOS` 下面的 `Secrecy.framwork` 到项目 `Targets`, `General` 设置标签的 `Linked Frameworks and Linraries` 中；

	![secrecy-1](http://7vihfk.com1.z0.glb.clouddn.com/secrecy-1.png)
	
4. 在 `Targes` 的 `Build Phases` 设置中，点击 `+` 按钮，添加 `New Run Script Phase` 来添加脚本:

		/usr/local/bin/carthage copy-frameworks
		
	同时在下面的 `Input Files` 中添加:

		$(SRCROOT)/Carthage/Build/iOS/Secrecy.framework
		
	![secrecy-2](http://7vihfk.com1.z0.glb.clouddn.com/secrecy-2.png)
		
### 手动安装

#### 通过 Git Submodule

通过 Submodule 将 SecrecySwift 作为 Embedded Framework 添加到项目中。

1. 首先确保项目已经在 git 仓库中;
2. 添加 `SecrecySwift` 作为 Submodule:

		git submodule add https://github.com/adow/SecrecySwift.git

3. 在 Xcode 中打开项目，将 SecrecySwift.xcodeproj 拖放到你的项目的根目录下;
4. 在你的项目下，选择 `Targets` , `General` 中添加 `Embedded Binaries`, 选择 `Secrecy.framework`, 确保 `Build Phases` 中的 `Link Binary with Libraries` 中有 `Secrecy.framework`;


#### 项目中直接部署源代码 (兼容iOS7)

1. 复制 `SecrecySwift` 目录下的这些文件到项目中

	* AES.swift
	* Digest.swift
	* HMAC.swift
	* RSA.swift
	* SecrecyExtension.swift

2. 在项目根目录下建立一个 CommonCrypto, 并建立一个 module.map 文件

		module CommonCrypto [system] {
		    header "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/include/CommonCrypto/CommonCrypto.h"
		    link "CommonCrypto"
		    export *
		}

3. 在项目 Targets 的 `Build Settings` 中添加 `Import Paths` 中添加 `CommonCrypto`, 在 `Library Search Path` 中添加 `/usr/lib/system`。

4. 在 `Targets` 中 `Build Phases` 的 `Link Binary with Libraries` 中添加 `Security.framework` 和 `SystemConfiguration.framework`。

这样就不需要 `import Secrecy`, 直接使用里面的函数了；

### 为什么没有 Cocoapods

我尝试了好多次使用 `Cocoapods` 发布，但是实在没有制作 Cocoapods 的经验，好像是由于需要链接 `CommonCrypto` 的缘故，我参考了很多人写的 podspec 文件，仍然无法正确的链接 `CommonCrypto`, `pod lib lint` 一直都失败。如果您知道如何正确的为这个项目写一个 `podspec`,请一定要发一个 Pull Request 给我。

## 使用

### 摘要和 HMAC

只要方法来自 SwiftSSL 项目: [https://github.com/SwiftP2P/SwiftSSL](https://github.com/SwiftP2P/SwiftSSL)

支持以下的摘要方法

* MD2；
* MD4；
* MD5；
* SHA1;
* SHA224；
* SHA256；
* SHA384；
* SHA512；

#### 摘要方法:

NSData/String 的 `digestHex/digestBase64` 支持将摘要输出为 hex 和 base64 字符串;

		let raw = "abc123"
		print(raw.digestHex(DigestAlgorithm.MD5))
		print(raw.digestBase64(DigestAlgorithm.MD5))


#### HMAC 签名方法

NSData/String 的 `signHex/signBase64` 方法支持签名输出为 hex 和 base64 字符串;

		let raw = "abc123"
		print(raw.signHex(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "你好"))


### AES 


支持 AES 模式 :

* EBC;
* CBC: 

** 只支持 PKCSPaddding7 的补齐方式；** 

根据提供的 Key 的长度，支持以下的加密方法

* AES128: 16位
* AES192: 24位;
* AES256: 32位;


#### EBC 模式

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

#### CBC 模式  

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

### RSA 

** 只支持 `.der` 文件格式的公钥和 `.p12` 格式的私钥 (而 PHP/Java/Python 这些平台使用 pem 文件)；只支持 PKCS1Padding 的补齐； **

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


#### 加密和解密

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
		
## 测试 

* 如何在 Python 中验证和 SecrecySwift 相同功能的示例 [SecrecyTestPy/test.py](SecrecyTestPy/test.py)
		
## References

* [【加密解密】加密解密介绍](http://www.jianshu.com/p/98610bdc9bd6)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [AES.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/AES.swift)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [RSA加密](http://blog.cnbluebox.com/blog/2014/03/19/rsajia-mi/)
* [RSA.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/RSA.swift)
