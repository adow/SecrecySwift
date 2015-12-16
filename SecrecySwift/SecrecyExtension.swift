//
//  Extension.swift
//  TestCommonCrypto
//
//  Created by 秦 道平 on 15/12/11.
//  Copyright © 2015年 秦 道平. All rights reserved.

import Foundation

/**
 * Index
 */
extension Int {
    public subscript(digitIndex: Int) -> Int {
        var decimalBase = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
        return (self / decimalBase) % 10
    }
}

extension UInt {
    public subscript(digitIndex: Int) -> UInt {
        var decimalBase:UInt = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
            return (self / decimalBase) % 10
    }
}

extension UInt8 {
    public subscript(digitIndex: Int) -> UInt8 {
        var decimalBase:UInt8 = 1
            for _ in 1...digitIndex {
                decimalBase *= 10
            }
            return (self / decimalBase) % 10
    }
}
extension NSData {
    /// 输出 hex 字符串
    public func hexadecimalString() -> String {
        let string = NSMutableString(capacity: length * 2)
        var byte: UInt8 = 0
        for i in 0 ..< length {
            getBytes(&byte, range: NSMakeRange(i, 1))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }
    /// 输出 hex 字符串
    public var hexString : String {
        return self.hexadecimalString()
    }
    /// 输出 base64 字符串
    public var base64String:String {
        return self.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
    }
    public func arrayOfBytes() -> [UInt8] {
        let count = self.length / sizeof(UInt8)
        var bytesArray = [UInt8](count: count, repeatedValue: 0)
        self.getBytes(&bytesArray, length:count * sizeof(UInt8))
        return bytesArray
    }
}
extension String {
    public var arrayOfBytes:[UInt8] {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        return data.arrayOfBytes()
    }
//    public var bytes:[UInt8]{
//        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
//        return data.arrayOfBytes()
//    }
    public var bytes:UnsafePointer<Void>{
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        return data.bytes
    }
    func dataFromHexadecimalString() -> NSData? {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<> ")).stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // make sure the cleaned up string consists solely of hex digits, and that we have even number of them
        guard let regex = try? NSRegularExpression(pattern: "^[0-9a-f]*$", options: NSRegularExpressionOptions.CaseInsensitive) else{
            return nil
        }
        let trimmedStringLength = trimmedString.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        let found = regex.firstMatchInString(trimmedString, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, trimmedStringLength))
        if found == nil || found?.range.location == NSNotFound || trimmedStringLength % 2 != 0 {
            return nil
        }
        
        // everything ok, so now let's build NSData
        
        let data = NSMutableData(capacity: trimmedStringLength / 2)
        
        for var index = trimmedString.startIndex; index < trimmedString.endIndex; index = index.successor().successor() {
            let byteString = trimmedString.substringWithRange(Range<String.Index>(start: index, end: index.successor().successor()))
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data?.appendBytes([num] as [UInt8], length: 1)
        }
        
        return data
    }
}