//
//  NSObject+Reflect.swift
//  RecruitProjectSwift
//
//  Created by 刘双 on 16/3/18.
//  Copyright © 2016年 sliu. All rights reserved.
//

import UIKit

extension String {

    
    //MARK: 清除字符串小数点末尾的0
    func cleanDecimalPointZear() -> String {
        let newStr = self as NSString
        var s = NSString()
        var offset = newStr.length - 1
        while offset > 0 {
            s = newStr.substringWithRange(NSMakeRange(offset, 1))
            if s.isEqualToString("0") || s.isEqualToString(".") {
                offset -= 1
            } else {
                break
            }
        }
        return newStr.substringToIndex(offset + 1)
    }
    
    //MARK:设置字符串属性
    func attributedString(color:UIColor,fontSize:CGFloat) -> NSAttributedString {
        let dic = [NSFontAttributeName:UIFont.systemFontOfSize(fontSize),NSForegroundColorAttributeName:color]
        return   NSAttributedString(string: self, attributes: dic)
    }
    
    
    //MARK: - 判断是不是正确的手机号码
    func isTelNumber()->Bool
    {
        
        
        let regex:NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "^((13[0-9])|(147)|(15[^4,\\D])|(18[0-9])|(17[0-9]))\\d{8}$", options: NSRegularExpressionOptions.CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions.ReportCompletion , range: NSMakeRange(0, self.characters.count))
            if matches.count > 0 { return true }
            else { return false  }
        }
        catch{
            
            return false
        }
        
    }
    
    //MARK: - 判断是不是身份证号码
    func isIDNumber()->Bool
    {
        
        
        let regex:NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: "^(\\d{14}|\\d{17})(\\d|[xX])$", options: NSRegularExpressionOptions.CaseInsensitive)
            let matches = regex.matchesInString(self, options: NSMatchingOptions.ReportCompletion , range: NSMakeRange(0, self.characters.count))
            if matches.count > 0 { return true }
            else { return false  }
        }
        catch{
            
            return false
        }
        
    }
    
       
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.startIndex.advancedBy(r.startIndex)
            let endIndex = self.startIndex.advancedBy(r.endIndex)
            
            //            let r = Range(startIndex...endIndex)
            
            return self[Range(startIndex...endIndex)]
        }
    }
    
    //MARK: - 计算字符串的高
    func height(width:CGFloat,fontSize:CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize)]
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let size = CGSizeMake(width, CGFloat(MAXFLOAT))
        let rect:CGRect = self.boundingRectWithSize(size, options: option, attributes: attributes, context: nil)
        return rect.height
    }
    
    //MARK: - 计算字符串的宽
    func width(height:CGFloat,fontSize:CGFloat) -> CGFloat {
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(fontSize)]
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let size = CGSizeMake(CGFloat(MAXFLOAT), height)
        let rect:CGRect = self.boundingRectWithSize(size, options: option, attributes: attributes, context: nil)
        return rect.width
    }

    
    static  func randomText(length: Int, justLowerCase: Bool = false, whitespace: Bool = false) -> String {
        var text = ""
        for _ in 1...length {
            var decValue = 0  // ascii decimal value of a character
            var charType = 3  // default is lowercase
            if justLowerCase == false {
                // randomize the character type
                charType =  Int(arc4random_uniform(4))
            }
            switch charType {
            case 1:  // digit: random Int between 48 and 57
                decValue = Int(arc4random_uniform(10)) + 48
            case 2:  // uppercase letter
                decValue = Int(arc4random_uniform(26)) + 65
            case 3:  // lowercase letter
                decValue = Int(arc4random_uniform(26)) + 97
            default:  // space character
                if whitespace {
                    decValue = 32
                } else {
                    // upper case letter
                    decValue = Int(arc4random_uniform(26)) + 65
                }
            }
            // get ASCII character from random decimal value
            let char = String(UnicodeScalar(decValue))
            text = text + char
            // remove double spaces if existing
            text = text.stringByReplacingOccurrencesOfString("  ", withString: " ")
        }
        return text
    }
    
    
    //MARK: - String转时间戳
    /** String转时间戳 13位
     */
    func stringTotimeTamp(format:String) -> String {
        let dfmatter = NSDateFormatter()
        dfmatter.dateFormat=format
        let date = dfmatter.dateFromString(self)
        let dateStamp:NSTimeInterval = date!.timeIntervalSince1970*1000
        let dateSt:Int64 = Int64(dateStamp)
        return String(dateSt)
    }
    
    //MARK: - 时间戳转String
    /** 时间戳转String
     */
    func timeTampToString(format:String = "YYYY-MM-dd hh:mm:ss") -> String {
        let outputFormat = NSDateFormatter()
        var myDataSource: NSString = self
        
        if myDataSource.length == 13 {
            
            myDataSource = myDataSource.substringToIndex(10)
            
        }else if myDataSource.length == 15 {
            myDataSource = String(myDataSource.integerValue / 1000)
            
        }
        
        //格式化规则
        // outputFormat.dateFormat = "yyyy/MM/dd HH:mm:ss"
        outputFormat.dateFormat = format
        //发布时间
        let pubTime = NSDate(timeIntervalSince1970: myDataSource.doubleValue)
        return  outputFormat.stringFromDate(pubTime)
    }

    
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(substring: String) -> Bool {
        return rangeOfString(substring) != nil
    }
    
    
    
    /// EZSE: Checking if String contains input with comparing options
    public func contains(find: String, compareOption: NSStringCompareOptions) -> Bool {
        return self.rangeOfString(find, options: compareOption) != nil
    }
    
    /// EZSE: Converts String to Int
    public func toInt() -> Int? {
        if let num = NSNumberFormatter().numberFromString(self) {
            return num.integerValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Double
    public func toDouble() -> Double? {
        if let num = NSNumberFormatter().numberFromString(self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NSNumberFormatter().numberFromString(self) {
            return num.floatValue
        } else {
            return nil
        }
    }

    
}