//
//  NSObject+HMDB.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@objc protocol HMDBModelDelegate:NSObjectProtocol {
    func dbFields()->[String]
    func dbPrimaryKey()->String?
    
    @objc optional func valueHaveChangedForKeys()->[String]
    @objc optional func changedValueHaveSaved()
}

var classPropertyInfos:[String:[String:String]] = [:]
var tableFieldInfos:[String:[String:String]] = [:]
var tablePrimaryKeyName:[String:String] = [:]

extension NSObject {
    
    static private var kdefaultPK =  "HMDBdefaultPK"
    static private var kisExistInDB =  "HMDBisExistInDB"
    
    private var defaultPK:Int{
        get{
            return objc_getAssociatedObject(self , &NSObject.kdefaultPK) as? Int ?? 0
        }
        set{
            objc_setAssociatedObject(self , &NSObject.kdefaultPK, newValue , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var isExistInDB:Bool{
        get{
            return objc_getAssociatedObject(self , &NSObject.kisExistInDB) as? Bool ?? false
        }
        set{
            objc_setAssociatedObject(self , &NSObject.kisExistInDB, newValue , .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    class func sqlOfCreateTable(cls:AnyClass)->String{
        
//        let cls:AnyClass = self.classForCoder
        let tableName:String = "\(cls)"
        var colums:String = ""
        
        if let obj:HMDBModelDelegate = self as? HMDBModelDelegate{
            let storeFields = obj.dbFields()
            let primaryKey = obj.dbPrimaryKey() ?? ""
            
            var realDbFields:[String:String] = [:]
            var classPropertyTypes:[String:String] = [:]
            
            let properties = (obj as! NSObject).getAllPropertys(theClass: cls , includeSupers: true )
            
            for field in storeFields{
                
                if properties.contains(field){
                    let property = class_getProperty(cls, field)
                    let attribute = String.init(utf8String: property_getAttributes(property)) ?? "1,1"
                    
                    let rawType:String = attribute.components(separatedBy: ",").first!
                    var sqlType:String = ""
                    
                    if rawType == "Tq" || rawType == "Ti" || rawType == "Ts" || rawType == "Tl"{
                        sqlType = "integer"
                    }else if rawType == "TQ" || rawType == "TI" || rawType == "TS" || rawType == "TL"{
                        sqlType = "integer"
                    }else if rawType == "Tf"{
                        sqlType = "single"
                    }else if rawType == "Td"{
                        sqlType = "double"
                    }else if rawType == "T@\"NSString\"" || rawType == "T@\"NSMutableString\""{
                        sqlType = "text"
                    }else if rawType == "T@\"NSArray\"" || rawType == "T@\"NSMutableArray\""{
                        debugPrint("database not surport for array type of \(field)")
                        
                    }else if rawType == "T@\"NSDictionary\"" || rawType == "T@\"NSMutableDictionary\""{
                        debugPrint("database not surport for dictionary type of \(field)")
                        
                    }else if rawType == "T@\"NSNumber\"" {
                        sqlType = "double"
                    }else if rawType == "TB"  {
                        sqlType = "integer"
                    }else if rawType == "T@\"NSDate\""{
                        sqlType = "date"
                    }else if rawType == "T@\"NSData\"" || rawType == "T@\"NSMutableData\""{
                        sqlType = "text"
                    }else if rawType.contains("NSURL"){
                        sqlType = "text"
                    }else{
                        debugPrint("database not surport for type of \(field)")
                    }
                    
                    if sqlType.characters.count > 0 {
                        if primaryKey == field{
                            colums.append("\(field) \(sqlType) primary key,")
                            
                            tablePrimaryKeyName.updateValue(field, forKey: tableName)
                        }else{
                            colums.append("\(field) \(sqlType),")
                        }
                        realDbFields.updateValue(sqlType, forKey: field)
                        classPropertyTypes.updateValue(rawType, forKey: field)
                    }
                }
                
                if primaryKey.characters.count == 0 {
                    colums.append("defaultPK integer primary key")
                    tablePrimaryKeyName.updateValue("defaultPK", forKey: tableName)
                }
                
                tableFieldInfos.updateValue(realDbFields, forKey: tableName)
                classPropertyInfos.updateValue(classPropertyTypes, forKey: tableName)
            }
            
            if colums.hasSuffix(","){
                colums = (colums as NSString).substring(to: colums.characters.count - 1)
            }
        }
        
        if colums.characters.count == 0 {
            debugPrint("create table \(tableName) but has no surported dbFields")
            return ""
        }
        return "CREATE TABLE IF NOT EXISTS \(tableName) (\(colums))"
    }
    
    
    public convenience init(primaryKey:Any?){
        self.init()
        let tableName:String = "\(self.classForCoder)"
        let primaryKey:String = tablePrimaryKeyName[tableName] ?? ""
        let pkvalue = NSObject.serialized(value: primaryKey) ?? ""
        let sql = "select * from \"\(tableName)\" where \"\(primaryKey)\" = ?"
        
        var fieldValues:[AnyHashable:Any ] = [primaryKey:pkvalue]
        let rs =  HMDBManager.shared.dataBase.executeQuery(sql , withArgumentsIn: [pkvalue])
        if rs?.next() ?? false{
            if rs!.resultDictionary != nil {
                fieldValues = rs!.resultDictionary!
                self.isExistInDB = true
            }
        }
        rs?.close()
        
        self.setValuesWith(fieldValues: fieldValues)
    }
    
    func setValuesWith(fieldValues:[AnyHashable:Any]){
        let tableName:String = "\(self.classForCoder)"

        let fields:[String:String] = tableFieldInfos[tableName] ?? [:]
        for obj in fieldValues{
            if fields[obj.key as? String ?? ""]?.characters.count ?? 0 > 0 {
                self.decode(dbValue: obj.value, forkey: obj.key as! String)
            }
        }
    }
    
    func dbAdd(completion:((Bool)->Void)){
        
    }
    func dbUpdate(completion:((Bool)->Void)){
        
    }
    
    func dbSave(completion:((Bool)->Void)){
        
    }
    

    func encodeValueFor(key:String)->Any?{
        return NSObject.serialized(value:self.value(forKey: key))
    }
    
    func decode(dbValue:Any?,forkey:String){
        let value = NSObject.unserialized(dbvalue: dbValue , propertyName: forkey)
        self.setValue(value , forKey: forkey)
    }
    
    class func serialized(value:Any?)->Any?{
        if let array = value as? [Any]{
            do{
                let data = try JSONSerialization.data(withJSONObject: array, options: .init(rawValue: 0))
                
                return self.stringFrom(data: data)
            }catch{
                debugPrint("can not serialized for array value:\(String(describing: value))")
                return ""
            }
        }else if let dic = value as? [AnyHashable:Any]{
            do{
                let data = try JSONSerialization.data(withJSONObject: dic, options: .init(rawValue: 0))
                return self.stringFrom(data: data)
            }catch{
                debugPrint("can not serialized for dictionary value:\(String(describing: value))")
                return ""
            }
        }else if let url = value as? URL {
            return url.absoluteString
        }else if let date = value as? Date {
            return date.timeIntervalSince1970
        }else if let data = value as? Data {
            return self.stringFrom(data: data )
        }
        
        return value
    }
    class func unserialized(dbvalue:Any?,propertyName:String)->Any?{
        let tablename = "\(self.classForCoder())"
        let classPropertys = classPropertyInfos[tablename] ?? [:]
        let type = classPropertys[propertyName] ?? ""
        if type.contains("NSArray")
            || type.contains("NSMutableArray")
            || type.contains("NSDictionary")
            || type.contains("NSMutableDictionary"){
            let str = dbvalue as? String ?? ""
            
            let data = self.dataFrom(string: str)
            do {
                let obj = try JSONSerialization.jsonObject(with: data , options: .init(rawValue: 0))
                
                if type.contains("NSArray"){
                    return obj as? [Any] ?? []
                }else if type.contains("NSMutableArray"){
                    return NSMutableArray.init(array:  obj as? [Any] ?? [])
                }else if type.contains("NSDictionary"){
                    return obj as? [AnyHashable:Any] ?? [:]
                }else if type.contains("NSMutableDictionary"){
                    return NSMutableDictionary.init(dictionary: obj as? [AnyHashable:Any] ?? [:])
                }
            }catch{
                debugPrint("can not unserialized for value:\(String(describing: dbvalue))")
                if type.contains("NSArray"){
                    return []
                }else if type.contains("NSMutableArray"){
                    return NSMutableArray.init(array:  [])
                }else if type.contains("NSDictionary"){
                    return [:]
                }else if type.contains("NSMutableDictionary"){
                    return NSMutableDictionary.init(dictionary: [:])
                }
            }
        }else if type.contains("NSDate"){
            let timeInterval = dbvalue as? Double ?? 0
            return Date.init(timeIntervalSince1970: timeInterval)
        }else if type.contains("NSData") || type.contains("NSMutableData"){
            let str = dbvalue as? String ?? ""
            if type.contains("NSData"){
                return self.dataFrom(string: str)
            }else{
                return NSMutableData.init(data: self.dataFrom(string: str))
            }
        }else if type.contains("NSURL"){
            let str = dbvalue as? String ?? ""
            return URL.init(string: str)!
        }
        return dbvalue
    } 
    
    class func stringFrom(data:Data)->String{
        return String.init(data: data , encoding: .utf8) ?? ""
    }
    class  func dataFrom(string:String)->Data{
        return string.data(using: .utf8) ?? Data()
    }
    
    
}
