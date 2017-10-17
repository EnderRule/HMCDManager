//
//  HMDBManager.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import Foundation




import FMDB
import FMDBMigrationManager


let disableHMDBLog:Bool = false

extension NSObject{
    class func newObjFor(subCls:AnyClass) ->AnyObject{
        
        return  (subCls as! NSObject.Type).init()
    }
}



class HMDBManager: NSObject {
    
    static let shared = HMDBManager()
    
    var modelClasses:[AnyClass] = []
    var dbUserID:String = ""
    
    var classPropertyInfos:[String:[String:String]] = [:]
    var tableFieldInfos:[String:[String:String]] = [:]
    var primarykeyFieldsInfo:[String:[String]] = [:]
    
    var dataBaseQueue:FMDatabaseQueue!
    var dataBase:FMDatabase!
    
    func addDBModelClass(cls:AnyClass){

        self.modelClasses.append(cls)
        if dataBase.open(){
            let _ = self.createTableFor(cls: cls,database: dataBase)
        }
    }
    
    var dbPath:String{
        let path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true ).first! as NSString).appendingPathComponent("mydb\(dbUserID).sqlite")
        
        if !FileManager.default.fileExists(atPath: path ){
            FileManager.default.createFile(atPath: path, contents: nil , attributes: nil )
        }
        return path
    }
    
    
    func openDB(userID:String,dbVersionBuilder:((Int)->Int)){
        
        if dataBaseQueue != nil{
            dataBaseQueue.close()
        }
        if dataBase != nil {
            dataBase.close()
        }
        
        dataBaseQueue = FMDatabaseQueue.init(path: dbPath)
        dataBase = FMDatabase.init(path: dbPath)
        
        if dataBase.open(){
            dataBaseQueue.inDatabase({ (db ) in
                
                var lastDBVersion:Int = 0
                let rs = db.executeQuery("PRAGMA user_version", withArgumentsIn: [])
                if rs?.next() ?? false {
                    lastDBVersion = Int(rs!.int(forColumnIndex: 0))
                }
                rs?.close()
                
                let newversion = dbVersionBuilder(lastDBVersion)
                debugPrint("new db version:\(newversion) lastV:\(lastDBVersion)")
                if newversion > lastDBVersion{
                    if !db.executeUpdate("PRAGMA user_version = \(newversion)", withArgumentsIn: []){
                        disableHMDBLog ? () : debugPrint("update DB user_version \(newversion) failure ")
                    }

                    self.clearAllTables()
                }
                
                //创建表
                for cls in self.modelClasses{
                    let _ = self.createTableFor(cls: cls,database: db )
                }
            })
        }else{
            disableHMDBLog ? () : debugPrint("fail to open db at :\(dbPath)")
        }
        
        
//        dataBaseQueue.inDatabase { (database) in
//            var schemeVersion:Int32 = 0
//            let set = database.executeQuery("PRAGMA user_version", withArgumentsIn: [])
//            if set?.next() ?? false {
//                schemeVersion = set!.int(forColumnIndex: 0)
//            }
//            set?.close()
//            
//            database.beginTransaction()
//            
//        }
        
    }
    func createTableFor(cls:AnyClass,database:FMDatabase)->Bool{

        let sql:String = self.sqlOfCreateTable(cls:cls)
        if sql.characters.count == 0 {
            return false 
        }
        
        database.shouldCacheStatements = true
        if !database.executeUpdate(sql , withArgumentsIn: []) {
            return false
        }
        return true
        
//        let tableName = "\(cls)"
//        var currentColumns:[String] = []
//        var currentPrimarykeys:[String] = []
//        let rs = database.getTableSchema(tableName)
//        while rs.next(){
//            let dic = rs.resultDictionary ?? [:]
//            let column = dic["name"] as? String ?? ""
//            
//            if rs.bool(forColumn: "pk"){
//                currentPrimarykeys.append(column)
//            }
////            debugPrint("\(tableName) \(column) info:\(dic)")
//            
//            if column.characters.count > 0 {
//                currentColumns.append(column)
//            }
//        }
        
//        var shouldAddColumns:[String] = []
//        
//        let expectedColumns = ((tableFieldInfos[tableName] ?? [:]) as NSDictionary).allKeys as! [String]
//        for obj in expectedColumns{
//            if !currentColumns.contains(obj){
//                shouldAddColumns.append(obj)
//            }
//        }
//        for column in shouldAddColumns{
//            let sqltype = self.sqlTypeOf(cls: cls, field: column).last!
//            if sqltype.characters.count > 0 {
//                if  !self.alertTable(cls: cls , addColumn: column, type: sqltype,database:dataBase){
//                    disableHMDBLog ? () : debugPrint("fail to alert table \(tableName) add column \(column) \(sqltype)")
//                }
//            }
//        }
        
        
//        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate{
//            var primarykeyFields = obj.dbPrimaryKeys()
//            if primarykeyFields.count <= 0 {
//                primarykeyFields = ["defaultPK"]
//            }
//            
//            let currentFieldsStr:String = (currentPrimarykeys.sorted() as NSArray).componentsJoined(by: ",")
//            let newFieldsStr:String = (primarykeyFields.sorted() as NSArray).componentsJoined(by: ",")
//            
//            if currentFieldsStr != newFieldsStr{
//
//                let result = self.alterTablePrimaryKey(cls: cls , oldFields: currentFieldsStr, newFields: newFieldsStr,database:dataBase)
////                disableHMDBLog ? () :
//                    debugPrint("\(result) to alter \(tableName) PrimaryKey  old:\(currentFieldsStr) new:\(newFieldsStr)")
//
//            }
//        }
        
        return true
        
    }
    
    func alertTable(cls:AnyClass,addColumn:String,type:String,database:FMDatabase)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) add \(addColumn) \(type)"
        
        return database.executeStatements(sql )
    }
    
    func alertTable(cls:AnyClass,alertColumn:String,newType:String,database:FMDatabase)->Bool{
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) alert column \(alertColumn) \(newType)"
        
        return database.executeStatements(sql )
    }
    func alterTablePrimaryKey(cls:AnyClass,oldFields:String,newFields:String,database:FMDatabase)->Bool{
//        如果表之前有主键则先删除：
//        alter table 表名 drop constraint 主键名
//        修改主键：
//        alter table 表名 add constraint 主键名 primary key (column1,column2,....,column)
        
        let tableName = "\(cls)"
        let dropSql = "alter table \(tableName) delete \(oldFields)"
        let addSql = "alter table \(tableName) add primary key(\(newFields))"
        
        if database.executeUpdate(dropSql, withArgumentsIn: []){
            let result = database.executeUpdate(addSql, withArgumentsIn: [])
            if !result{
                debugPrint("alter Table PrimaryKey: add new failure:\(addSql)")
            }
            return result
        }else{
            debugPrint("alter Table PrimaryKey: drop old failure:\(dropSql)")
            return false
        }
        
        
    }
    
    func alertTable(cls:AnyClass,deleteColumn:String,database:FMDatabase)->Bool{
        
        let tableName = "\(cls)"
        
        let sql = "alter table \(tableName) drop \(deleteColumn)"
        
        return database.executeStatements(sql )
    }
    
    func clearAllTables(){
        debugPrint("clearAllTables :\(self.modelClasses)")
        for cls in self.modelClasses{
            let tableName:String = "\(cls.class())"
            let result = self.clearTable(name: tableName)
            disableHMDBLog ? () : debugPrint("clear table \(tableName) \(result)")
        }
    }
    func clearTable(name:String)->Bool{
        dataBase.shouldCacheStatements = true
        return dataBase.executeUpdate("delete from \(name)", withArgumentsIn: [])
    }
    
    func sqlOfCreateTable(cls:AnyClass)->String{
        
        let tableName:String = "\(cls)"
        var colums:String = ""
        
        var primaryKeys:[String] = []
        if let obj = (cls as! NSObject.Type).init() as? HMDBModelDelegate {
            
            let storeFields = obj.dbFields()
            
            primaryKeys = obj.dbPrimaryKeys()
            if primaryKeys.count <= 0 {
                primaryKeys = ["defaultPK"]
            }
            
            var realDbFields:[String:String] = [:]
            var classPropertyTypes:[String:String] = [:]
            
            let properties = (obj as! NSObject).getAllPropertys(theClass: cls , includeSupers: true )
            
            for field in storeFields{
                
                if properties.contains(field){
                    
                    let types = self.sqlTypeOf(cls: cls , field: field)
                    let sqlType = types.last!
                    let rawType = types.first!
                    
                    if sqlType.characters.count > 0 {
                        colums.append("\(field) \(sqlType),")
                        
                        realDbFields.updateValue(sqlType, forKey: field)
                        classPropertyTypes.updateValue(rawType, forKey: field)
                    }
                }
            }
            if primaryKeys.first! == "defaultPK"{
                colums.append("defaultPK integer")
                realDbFields.updateValue("integer", forKey: "defaultPK")
            }
            primarykeyFieldsInfo.updateValue(primaryKeys, forKey: tableName)
            tableFieldInfos.updateValue(realDbFields, forKey: tableName)
            classPropertyInfos.updateValue(classPropertyTypes, forKey: tableName)

            if colums.hasSuffix(","){
                colums = (colums as NSString).substring(to: colums.characters.count - 1)
            }
        }else{
            disableHMDBLog ? () : debugPrint("class \(cls) is not in db handled ")
        }
        
        if colums.characters.count == 0 {
            disableHMDBLog ? () : debugPrint("create table \(tableName) but has no surported dbFields")
            return ""
        }
        var primaryFieldsStr = ""
        if  primaryKeys.count == 1 {
            primaryFieldsStr = primaryKeys.first!
        }else{
            primaryFieldsStr = (primaryKeys as NSArray).componentsJoined(by: ",")
        }
        let createTableSQL =  "CREATE TABLE IF NOT EXISTS \(tableName)(\(colums),primary key(\(primaryFieldsStr)))"

        return createTableSQL
    }
    
    
    func sqlTypeOf(cls:AnyClass,field:String)->[String]{

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
        }else if rawType == "TB"  { //bool 值
            sqlType = "integer"
        }else if rawType.contains("NSDate"){
            sqlType = "double"
        }else if rawType.contains("NSURL"){
            sqlType = "text"
        }else if rawType.contains("NSData") || rawType.contains("NSMutableData"){
            sqlType = "text"
        }else if rawType.contains("NSString") || rawType.contains("NSMutableString"){
            sqlType = "text"
        }else if rawType.contains("NSArray") || rawType.contains("NSMutableArray"){
            sqlType = "text"
        }else if rawType.contains("NSDictionary") || rawType.contains("NSMutableDictionary"){
            sqlType = "text"
        }else if rawType.contains("NSNumber") {
            sqlType = "double"
        }else{
            disableHMDBLog ? () : debugPrint("database not surport for type of \(field)")
        }
        
        return [rawType,sqlType]
    }
}


class MyDBMigration:NSObject,FMDBMigrating{
    var name: String!{
        return "MyDBMigration"
    }
    var version: UInt64{
        return 1
    }
    
    func migrateDatabase(_ database: FMDatabase!) throws {
      
        return
    }
}

