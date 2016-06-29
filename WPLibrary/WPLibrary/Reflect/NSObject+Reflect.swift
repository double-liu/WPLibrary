//
//  NSObject+Reflect.swift
//  RecruitProjectSwift
//
//  Created by 刘双 on 16/3/18.
//  Copyright © 2016年 sliu. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftString

//MARK - 通过字符串获取类
extension  NSObject
{
    /**
     - parameter className: 通过字符串获取类
     - returns: 类
     */
    class func ClassFromString(str: String) -> AnyClass!{
        
        if  var appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleExecutable") as? String {
            
            if appName == "" {appName = ((NSBundle.mainBundle().bundleIdentifier!).characters.split{$0 == "."}.map { String($0) }).last ?? ""}
            
            var clsStr = str
            
            if !str.contain("\(appName)."){
                clsStr = appName + "." + str
            }
            
            let strArr = clsStr.explode(".")
            
            var className = ""
            
            let num = strArr.count
            
            if num > 2 || strArr.contains(appName) {
                
                var nameStringM = "_TtC" + "C".repeatTimes(num - 2)
                
                for (_, s): (Int, String) in strArr.enumerate(){
                    
                    nameStringM += "\(s.characters.count)\(s)"
                }
                
                className = nameStringM
                
            }else{
                
                className = clsStr
            }
            
            return NSClassFromString(className)
        }
        
        return nil;
    }
}


extension  String
{
    func contain(subStr: String) -> Bool {return (self as NSString).rangeOfString(subStr).length > 0}
    func subCenterString(str1:String,str2:String)  -> String
    {
        if self.hasPrefix(str1) && self.hasSuffix(str2)
        {
            let typecount = self.characters.count
            return   (self as NSString).substringWithRange(NSMakeRange(str1.characters.count, typecount - str1.characters.count - str2.characters.count))
        }
        return self
    }
    
    func explode (separator: Character) -> [String] {
        return self.characters.split(isSeparator: { (element: Character) -> Bool in
            return element == separator
        }).map { String($0) }
    }
    
    func replacingOccurrencesOfString(target: String, withString: String) -> String{
        return (self as NSString).stringByReplacingOccurrencesOfString(target, withString: withString)
    }
    
    func deleteSpecialStr()->String{
        
        return self.replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
    }
    
    var floatValue: Float? {return NSNumberFormatter().numberFromString(self)?.floatValue}
    var doubleValue: Double? {return NSNumberFormatter().numberFromString(self)?.doubleValue}
    
    func repeatTimes(times: Int) -> String{
        var strM = ""
        for _ in 0..<times {
            strM += self
        }
        return strM
    }
}



//MARK:- 模型转字典
extension  NSObject
{
    public class func modelToDictionary(obj : Any) ->  [String : AnyObject] {
        
        let mirror = Mirror(reflecting: obj)
        var dic : [String : AnyObject] = [:]
        for case let (label?, values) in mirror.children {
            let  keyStr = String(label)
            if keyStr == "Some" {
                let dicModel =   NSObject.modelToDictionary(values)
                return dicModel
            }
            
            let tempStr = String(values)
            if tempStr == "nil" {
                continue
            }
            
            //类型处理
            var type:String =  String(Mirror(reflecting: values).subjectType)
            type  =  type.subCenterString("Optional<", str2: ">")
            if type.hasPrefix("String")
            {
                let  str = String(values).replacingOccurrencesOfString("Optional(", withString: "").replacingOccurrencesOfString(")", withString: "").replacingOccurrencesOfString("\"", withString: "")
                dic[String(label)] = str
                
            }else if type.hasPrefix("Dictionary")
            {
                dic[String(label)] = String(values)
                
            }else if type.hasPrefix("Array")
            {
                type = type.subCenterString("Array<", str2: ">")
                
                if type == "AnyObject"
                {
                    dic[String(label)] = String(values)
                }else
                {  //模型包含模型数组
                    
                    let modelDic = NSObject.ppto(values,key: String(label))
                    dic[String(label)] = modelDic
                }
                
            }else
            {
                
                if type == "AnyObject" { //其他没有被判断的类型 强转成String
                    let str = String(values)
                    dic[String(label)] = str
                }else{//模型包含模型
                    
                    let dicModel = NSObject.modelToDictionary(values)
                    dic[String(label)] = dicModel
                }
            }
        }
        
        let json = JSON(dic)
        
        let str = json.rawString()
        
        let jj = JSON.parse(str!)
        
        return jj.object as! [String : AnyObject]
    }
    
    
    public class func ppto(obj : Any,key :String) ->  Array<[String : AnyObject]> {
        
        let mirror = Mirror(reflecting: obj)
        
        var arr : Array<[String : AnyObject]> = []
        for case let (label?, values) in mirror.children {
            let  keyStr = String(label)
            if keyStr == "Some" {
                let dicModel =   NSObject.ppto(values,key: key)
                return dicModel
            }
            let dicModel = NSObject.modelToDictionary(values)
            arr.append(dicModel)
        }
        return arr
    }
    
    //MARK:-属性的类型
    class  private func sureType(name:String) -> Type {
        
        if name.hasPrefix("String"){
            // --> 可以扩展所有可以转成String
            return .String
        }else if  name.hasPrefix("Number")
        {
            return .Number
        }else if  name.hasPrefix("Array")
        {
            return .Array
        }else if  name.hasPrefix("Dictionary")
        {
            return .Dictionary
        }else if  name.hasPrefix("Bool")
        {
            return .Bool
        }else if  name.hasPrefix("Null")
        {
            return .Null
        }else if  name.hasPrefix("UI") || name.hasPrefix("NS")
        {
            print("不支持OC类型,请使用Swift")
            //不支持类型 空处理
            return .Null
            
        }else if  name.hasPrefix("Unknown")
        {   //对象类型
            return .Unknown
        }else
        {
            return .Unknown
        }
    }
    
    //MARK:字典数据转模型(基础类型全部用字符串)
    public  func modelFormAnyObject(dic:AnyObject) -> Self
    {
        let model = self
        let json = JSON(dic)
        let mirror = Mirror(reflecting: model)
        for case let (label?, values) in mirror.children {
            
            //类型处理
            var type:String =  String(Mirror(reflecting: values).subjectType)
            type  =  type.subCenterString("Optional<", str2: ">")
            let subJSON = json[label]
            switch NSObject.sureType(type) {
            case .String:
                //非空类型数据转String
                if subJSON.type != .Null{
                    model.setValue(String(subJSON.object), forKey: label)
                }
                break
            case .Number,.Bool,.Dictionary:
                if subJSON.type == NSObject.sureType(type) {
                    model.setValue(subJSON.object, forKey: label)
                }
                break
            case .Array:
                //数据是数组
                type  =  type.subCenterString("Array<", str2: ">")
                if subJSON.type == .Array{
                    if type == "AnyObject"
                    {
                        model.setValue(subJSON.object, forKey: label)
                    }else
                    {  //模型数组
                        let datalArr = subJSON.object as! Array<AnyObject>
                        let classType:AnyClass = NSObject.ClassFromString(type)
                        var modelArr:[AnyObject] = [AnyObject]()
                        for data  in datalArr
                        {
                            let  item =  classType.modelFormAnyObject(data)
                            modelArr.append(item)
                        }
                        model.setValue(modelArr, forKey: label)
                    }
                }
                
                break
            case.Unknown:
                //模型类型
                let classType:AnyClass = NSObject.ClassFromString(type)
                let subModel = classType.modelFormAnyObject(json[label].object)
                model.setValue(subModel, forKey: label)
                break
            default: break
                
            }
        }
        model.finishedConversion()
        return model
    }
    
    class  public  func modelFormAnyObject(dic:AnyObject) -> Self
    {
        let model = self.init()
        model.modelFormAnyObject(dic)
        return model
    }
    
    
    //MARK:数组字典转数组模型
    class  public  func modelArrayFromArrAy(dataArray:AnyObject) -> [AnyObject]
    {
        
        var modelArray = [AnyObject]()
        if let arr = dataArray as? [AnyObject] {
            for index in arr
            {
                if  let dic = index as? Dictionary<String,AnyObject>
                {
                    let model = self.modelFormAnyObject(dic)
                    modelArray.append(model)
                }
            }
        }
        return modelArray
    }
    
    //MARK: - 打印属性
    func printDic(dic:AnyObject,isSub:Bool = false)  {
        
        if let  obj = dic as? [String:AnyObject] {
            for (key,value) in obj {
                
                var spacing = ""
                if key.length < 15 {
                    for _ in 0...15-key.length {
                        spacing += " "
                    }
                }
                
                if let value1 = value as? Array<AnyObject> {
                    if isSub {
                        print("\n\n-------\(key)-------Array")
                        if value1.count != 0 {
                            self.printDic(value1.first as! [String : AnyObject])
                        }
                        
                        print("-------\(key)-------Array")
                    }else
                    {
                        print("var \(key)\(spacing):Array<AnyObject>!\n")
                    }
                    
                }else if let value2 = value as? [String:AnyObject]
                {
                    if isSub {
                        print("\n\n-------\(key)-------Dictionary")
                        self.printDic(value2)
                        print("-------\(key)-------Dictionary")
                    }else
                    {
                        print("var \(key)\(spacing):[String:AnyObject]!\n")
                    }
                    
                }else
                {    if !isSub {
                    print("var \(key)\(spacing):String!\n")
                    }
                }
            }
        }
        
        if !isSub {
            self.printDic(dic, isSub: true)
        }
        
    }
    
    func printDicShowValues(dic:AnyObject,isSub:Bool = false)
    {
        if let  obj = dic as? [String:AnyObject] {
            for (key,value) in obj {
                
                var spacing = ""
                if key.length < 15 {
                    for _ in 0...15-key.length {
                        spacing += " "
                    }
                }
                
                if let value1 = value as? Array<AnyObject> {
                    if isSub {
                        print("\n\n-------\(key)-------Array")
                        self.printDicShowValues(value1[0] as! [String : AnyObject])
                        print("-------\(key)-------Array")
                    }else
                    {
                        print("var \(key)\(spacing):Array<AnyObject>!\n")
                    }
                    
                }else if let value2 = value as? [String:AnyObject]
                {
                    if isSub {
                        print("\n\n-------\(key)-------Dictionary")
                        self.printDicShowValues(value2)
                        print("-------\(key)-------Dictionary")
                    }else
                    {
                        print("var \(key)\(spacing):[String:AnyObject]!\n")
                    }
                    
                }else
                {   if !isSub {
                    print("var \(key)\(spacing):\(value)\n")
                    }
                }
            }
        }
        
        if !isSub {
            self.printDicShowValues(dic, isSub: true)
        }
    }
    
    
    
    public  func toJSONString(obj:AnyObject) -> String{
        if let dic = obj as? [String:AnyObject] {
            let data = try! NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            var strJson:NSString = ""
            if NSString(data: data, encoding: NSUTF8StringEncoding) != nil {
                strJson = NSString(data: data, encoding: NSUTF8StringEncoding)!
            }
            return "\(strJson)"
        }else if let arr = obj as? [AnyObject]
        {
            var arrStr = ".["
            
            for item in arr {
                arrStr += "\(self.toJSONString(NSObject.modelToDictionary(item))),"
            }
            
            arrStr = arrStr.between(".", ",")!
            arrStr += "]"
            return  arrStr
        }
        return ""
    }
    
    
    
    //MARK:-转化完成
    func  finishedConversion() {
        
    }
    
}


