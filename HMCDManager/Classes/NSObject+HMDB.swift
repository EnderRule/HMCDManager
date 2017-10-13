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
    
//    @objc optional func valueHaveChangedForKeys()->[String]
//    @objc optional func changedValueHaveSaved()
}



extension NSObject {
    
    static private var kdefaultPK =  "HMDBdefaultPK"
    static private var kisExistInDB =  "HMDBisExistInDB"
    
    class var tableName:String{
        return "\(self.classForCoder())"
    }
    
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
        
        let tableName:String = "\(cls)"
        var colums:String = ""
    
        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate {
            
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
                        sqlType = "text"
                    }else if rawType == "T@\"NSDictionary\"" || rawType == "T@\"NSMutableDictionary\""{
                        sqlType = "text"
                    }else if rawType == "T@\"NSNumber\"" {
                        sqlType = "double"
                    }else if rawType == "TB"  {
                        sqlType = "integer"
                    }else if rawType == "T@\"NSDate\""{
                        sqlType = "double"
                    }else if rawType == "T@\"NSData\"" || rawType == "T@\"NSMutableData\""{
                        sqlType = "text"
                    }else if rawType.contains("NSURL"){
                        sqlType = "text"
                    }else{
                        debugPrint("database not surport for type of \(field)")
                    }
                    
//                    debugPrint("sql field ",field,sqlType,rawType)
                    
                    if sqlType.characters.count > 0 {
                        if primaryKey == field{
                            colums.append("\(field) \(sqlType) primary key,")
                            
                            HMDBManager.shared.tablePrimaryKeyName.updateValue(field, forKey: tableName)
                        }else{
                            colums.append("\(field) \(sqlType),")
                        }
                        realDbFields.updateValue(sqlType, forKey: field)
                        classPropertyTypes.updateValue(rawType, forKey: field)
                    }
                }
                
                if primaryKey.characters.count == 0 {
                    colums.append("defaultPK integer primary key")
                    HMDBManager.shared.tablePrimaryKeyName.updateValue("defaultPK", forKey: tableName)
                }
                
                HMDBManager.shared.tableFieldInfos.updateValue(realDbFields, forKey: tableName)
                HMDBManager.shared.classPropertyInfos.updateValue(classPropertyTypes, forKey: tableName)
            }
            
            if colums.hasSuffix(","){
                colums = (colums as NSString).substring(to: colums.characters.count - 1)
            }
        }else{
            debugPrint("class \(cls) is not in db handled ")
        }
        
        if colums.characters.count == 0 {
            debugPrint("create table \(tableName) but has no surported dbFields")
            return ""
        }
        return "CREATE TABLE IF NOT EXISTS \(tableName) (\(colums))"
    }
    
    
    public convenience init(primaryKey:Any,createIfNoneExist:Bool){
        self.init()
        let tableName:String = "\(self.classForCoder)"
        let primaryKey:String = HMDBManager.shared.tablePrimaryKeyName[tableName] ?? ""
        let pkvalue = NSObject.serialized(value: primaryKey)
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
    
    @objc func setValuesWith(fieldValues:[AnyHashable:Any]){
        let tableName:String = "\(self.classForCoder)"

        let fields:[String:String] = HMDBManager.shared.tableFieldInfos[tableName] ?? [:]
        for obj in fieldValues{
            if fields[obj.key as? String ?? ""]?.characters.count ?? 0 > 0 {
                self.decode(dbValue: obj.value, forkey: obj.key as! String)
            }
        }
    }
     
    @objc func dbAdd(completion:@escaping ((Bool)->Void)){
        self.dbSave(insert: true , completion: completion)
    }
    @objc func dbUpdate(completion:@escaping ((Bool)->Void)){
        self.dbSave(insert: false , completion: completion)
    }
    
    @objc func dbSave(completion:@escaping ((Bool)->Void)){
        self.dbSave(insert: nil , completion: completion)
    }
    
    private func dbSave(insert:Bool? ,completion:((Bool)->Void)?){
        
        let tableName:String = "\(self.classForCoder)"
        let primaryKey = (self as! HMDBModelDelegate).dbPrimaryKey() ?? "defaultPK"



        var dbvalues:[Any] = []
        
        var fields:[String] = ((HMDBManager.shared.tableFieldInfos[tableName] ?? [:]) as NSDictionary).allKeys as? [String] ?? []
        for field in fields{
            let dbvalue = self.encodeValueFor(key: field) // NSObject.serialized(value: self.value(forKey: field) ?? "")
            dbvalues.append(dbvalue)
        }
        if !fields.contains(primaryKey){
            fields.append(primaryKey)
            dbvalues.append(self.defaultPK)
        }
        
        if self.isExistInDB{
        
        
        }else{
            
            var action:String = ""
            if insert == nil {
                action = "insert or replace"
            }else if insert!{
                action = "insert"
            }else{
                action = "replace"
            }
            
            let columns = (fields as NSArray).componentsJoined(by: "\",\"")
            var valuesHolders = ("" as NSString).padding(toLength: fields.count * 2, withPad: "?,", startingAt: 0)
            valuesHolders = (valuesHolders as NSString).substring(to: valuesHolders.characters.count - 1)
            let sql:String = "\(action) into \"\(tableName)\" (\"\(columns)\") values (\(valuesHolders))"
            
            debugPrint("db save sql:\(sql) values:\(dbvalues)")
            
            let result = HMDBManager.shared.dataBase.executeUpdate(sql , withArgumentsIn: dbvalues)
            
            completion?(result)
        }
    }
    
    @objc func dbDelete(completion:((Bool)->Void)?){
        let tableName:String = "\(self.classForCoder)"
        let primaryKey = (self as! HMDBModelDelegate).dbPrimaryKey() ?? "defaultPK"
        let primaryValue = primaryKey == "defaultPK" ? self.defaultPK : self.encodeValueFor(key: primaryKey)
        let sql = "delete from \(tableName) where \(primaryKey) = \(primaryValue) "
       
        debugPrint("db delete sql:\(sql) ")
        completion?( HMDBManager.shared.dataBase.executeStatements(sql))
    }
    
    /// query
    ///
    /// - Parameters:
    ///   - whereStr: example: objid = 33  or name like "myname"
    ///   - orderFields: example: objid desc
    ///   - offset: default 0
    ///   - limitCount: default 0
    /// - Returns: entity objs as array
    @objc class func dbQuery(whereStr:String?,orderFields:String?,offset:Int,limit:Int,args:[Any],completion:@escaping (([Any],Error?)->Void)){
        let tableName:String = "\(self.classForCoder())"

        var sql:String = "select * from \(tableName) "
        if whereStr?.characters.count ?? 0 > 0 {
            sql.append(" where \(whereStr!) ")
        }
        if orderFields?.characters.count ?? 0 > 0{
            sql.append(" order by \(orderFields!) ")
        }
        if offset > 0 {
            sql.append(" offset \(offset) ")
        }
        if limit > 0 {
            sql.append(" limit \(limit) ")
        }
        
        debugPrint("db query sql:\(sql)")
        
        let rs =  HMDBManager.shared.dataBase.executeQuery(sql , withArgumentsIn: args)
        if rs != nil  {
            var objs:[AnyObject] = []
            while rs!.next() {
                let obj = (self.classForCoder() as! NSObject.Type).init()
                obj.setValuesWith(fieldValues: rs!.resultDictionary ?? [:])
                objs.append(obj)
            }
            completion(objs,nil)
        }else{
            completion([],HMDBManager.shared.dataBase.lastError())
        }
    }
    

    private func encodeValueFor(key:String)->Any{
        return NSObject.serialized(value:self.value(forKey: key) ?? "")
    }
    
    private func decode(dbValue:Any,forkey:String){
        let value = NSObject.unserialized(dbvalue: dbValue , propertyName: forkey)
        self.setValue(value , forKey: forkey)
    }
    
    class func serialized(value:Any)->Any{
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
    class func unserialized(dbvalue:Any,propertyName:String)->Any{
        let tablename = "\(self.classForCoder())"
        let classPropertys = HMDBManager.shared.classPropertyInfos[tablename] ?? [:]
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
        if ((dbvalue as? NSNull) != nil)  {
            return ""
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






