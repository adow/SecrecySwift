# SecrecySwift


SecrecySwift is a wrapper library for `CommonCrypto` and `Security.framework` in Swift. It provides crpyto related functions.

## Features 

* Digest and HMAC: `MD2`/`MD4`/`MD5`/`SHA1`/`SHA224`/`SHA384`/`SHA512`;
* AES Encrypt and Decrypt: `EBC`/`CBC`;
* RSA Encrypt/Decrypt and Sign/Verify with digest of `MD2`/`MD5`/`SHA1`/`SHA224`/`SHA384`;

## Installing

### Carthage

Carthage is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with Homebrew using the following command:

	$ brew update
	$ brew install carthage
	
Buid for iOS	
	
1. Create a Cartfile that lists the frameworks you’d like to use in your project.

		git "git@github.com:adow/SecrecySwift.git" == 0.3.1
	
2. Run `carthage update`. This will fetch dependencies into a Carthage/Checkouts folder, then build each one.
3. On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.
4. On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following contents:

		/usr/local/bin/carthage copy-frameworks
		
and add the paths to the frameworks you want to use under “Input Files”, e.g.:

		$(SRCROOT)/Carthage/Build/iOS/Secrecy.framework
	
### Manually 

#### Git Submodule

* Make sure that your project is in Git repository;
* Add `SecrecySwift` as submodule;

		git submodule add git@github.com:adow/SecrecySwift.git
	
* Drag and drop `SecrecySwift.xcodeproj` to your project;
* On your application targets, `General` tab, `Embedded Binaries` setting, click `+` to add `Secrecy.framework`. You will find `Secrecy.framework` is also in `Build Phases` / `Link Binary with Libraries`.


#### Add Source Code to your project (Compatible with iOS7)

Copy following files in folder `SecrecySwift` to your project:

* AES.swift
* Digest.swift
* HMAC.swift
* RSA.swift
* SecrecyExtension.swift

You should not `import Secrecy` any more.

## Usage


### Digest and HMAC

Digest.swift and HMAC.swift are forked from SwiftSSL: [https://github.com/SwiftP2P/SwiftSSL](https://github.com/SwiftP2P/SwiftSSL)

Following alagorithms are available.

* MD2；
* MD4；
* MD5；
* SHA1;
* SHA224；
* SHA256；
* SHA384；
* SHA512；

#### Digest:


Methods `digestHex/digestBase64` in `NSData` and `String` could be used to digest it to Hex or Base64 Strings.

		let raw = "abc123"
		print(raw.digestHex(DigestAlgorithm.MD5))
		print(raw.digestBase64(DigestAlgorithm.MD5))


#### HMAC Signarure

`signHex/signBase64` in `NSData` and `String` are signature methods to Hex and Base64 Strings. 

		let raw = "abc123"
		print(raw.signHex(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "abc"))
		print(raw.signBase64(HMACAlgorithm.SHA1, key: "你好"))


## AES 


It supports modes of:

* EBC;
* CBC: 

Only PKCSPadding7 for AES is supported. Following encrypt alagorithms are supported depending on the length of KEY.

* AES128: 16;
* AES192: 24;
* AES256: 32;

### EBC MODE

* `aesEBCEncrypt`: Encrypt in EBC Mode.
* `aesEBCDecryptFromHex` Decrypt in EBC Mode from a Hex String.
* `aesEBCDecryptBase64` Decrypt in EBC Mode from a Base64 String.

		let key = "0000000000000000"
		let raw = "0123456789abcdef"
		let encrypt_1 = raw.aesEBCEncrypt(key)
		print(encrypt_1!.hexString)
		print(encrypt_1!.hexString.aesEBCDecryptFromHex(key))
		print(encrypt_1!.base64String)
		print(encrypt_1!.base64String.aesEBCDecryptFromBase64(key))

### CBC Mode  

CBC Mode can use IV, which will be filled with Zero if not specificed.

* `aesCBCEncrypt` Encyrpt in CBC Mode;
* `aecCBCDecryptFromHex`: Decrypt in CBC mode from a Hex String.
* `aesCBCDecryptFromBase64`: Decrypt in CBC mode from a Base64 String.
		
		let iv = "0000000000000000"
		let encrypt = raw.aesCBCEncrypt(key,iv: iv)
		print(encrypt!.hexString)
		print(encrypt!.hexString.aesCBCDecryptFromHex(key,iv: iv))
		print(encrypt!.base64String)
		print(encrypt!.base64String.aesCBCDecryptFromBase64(key,iv: iv))

## RSA 

RSA in SecrecySwift supports file formats of `.der` for public key and `.p12` for private key. PKCS1Padding is used in RSA.

Generate certificates by `OpenSSL`:

	# Generate RSA Private Key
	openssl genrsa  -out private.pem  2048
	
	# Get Public Key (pem file) from private key
	openssl rsa  -pubout  -in private.pem  -out public.pem
	
	# Genrate Certificate Request from private key
	openssl req -new -key private.pem -out cert.csr
	
	# Generate Self-Signature Certificate from private key
	openssl x509 -req -days 3650 -in cert.csr -signkey private.pem -out cert.crt
	
	# Convert it to DER Format (Contains Public key)
	openssl x509 -outform der -in cert.crt -out cert.der
	
	# Export p12 file, with a password (Contains Private key)
	openssl pkcs12 -export -inkey private.pem -in cert.crt -out cert.p12


### Encrypt and Decrypt

Encrypt using Public Key

* `public func encrypt(data:NSData) -> NSData?`

Decrypt usign Private Key 

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

### Sign and Verify

You can use following alagorithms to sign:
 
* MD2;
* MD5;
* SHA1;
* SHA224;
* SHA256;
* SHA384；
* SHA512；


Sign using Private Key:

`public func sign(algorithm:RSAAlgorithm,inputData:NSData) -> NSData?`

Verify using Public Key:

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
		
## NSData Extension

* `hexString`:  Hex string;
* `base64String`: Base64 String
* `arrayOfBytes`: Array of UInt8


		extension NSData {
			public var hexString : String
			public var base64String:String
			public func arrayOfBytes() -> [UInt8]
		}
		
## String Extension

* `dataFromHexadecimalString`: Get NSData from Hex String;

		extenstion String {
			func dataFromHexadecimalString() -> NSData?
		}
		
## Test Script in Python 

* Checkout how to impletment same functions in Python as SecrecySwift. [SecrecyTestPy/test.py](SecrecyTestPy/test.py)
		
## References

* [【加密解密】加密解密介绍](http://www.jianshu.com/p/98610bdc9bd6)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [AES.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/AES.swift)
* [iOS 系统中 AES 和 RSA 算法的实现](http://kvmisc.github.io/blog/2015/02/10/implement-aes-and-rsa-algorithm-in-ios/)
* [RSA加密](http://blog.cnbluebox.com/blog/2014/03/19/rsajia-mi/)
* [RSA.swift](https://github.com/adow/SecrecySwift/blob/master/SecrecySwift/RSA.swift)