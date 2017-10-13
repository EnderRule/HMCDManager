//
//  HMDBManager.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/10/12.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import Foundation



//import fm
import FMDB


extension NSObject{
    class func newObjFor(subCls:AnyClass) ->AnyObject{
        
        return  (subCls as! NSObject.Type).init()
    }
}



class HMDBManager: NSObject {
    
    static let shared = HMDBManager()
    
    var modelClasses:[AnyClass] = []
    
    var classPropertyInfos:[String:[String:String]] = [:]
    var tableFieldInfos:[String:[String:String]] = [:]
    var tablePrimaryKeyName:[String:String] = [:]
    
    var dataBaseQueue:FMDatabaseQueue!
    var dataBase:FMDatabase!
    
    func setDBModelClasses(classes:[AnyClass]){
        self.modelClasses.removeAll()
        self.modelClasses.append(contentsOf: classes)
    }
    
    var dbPath:String{
        let path = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true ).first! as NSString).appendingPathComponent("mydb.sqlite")
        
        if !FileManager.default.fileExists(atPath: path ){
            FileManager.default.createFile(atPath: path, contents: nil , attributes: nil )
        }
        return path
    }
    
    var dbVersion:Int{
        get{
            return UserDefaults.standard.integer(forKey: "HMDBVersion")
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMDBVersion")
            UserDefaults.standard.synchronize()
        }
    }
    private var lastDBVersion:Int{
        get{
            return UserDefaults.standard.integer(forKey: "HMDBLastVersion")
        }
        set{
            UserDefaults.standard.setValue(newValue, forKey: "HMDBLastVersion")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    func openDB(){
        
        if dataBaseQueue != nil{
            dataBaseQueue.close()
        }
        if dataBase != nil {
            dataBase.close()
        }
        
        dataBaseQueue = FMDatabaseQueue.init(path: dbPath)
        dataBase = FMDatabase.init(path: dbPath)
        
        if dataBase.open(){
            
            if dbVersion > lastDBVersion {
                self.clearAllTables()
            }
            
            self.createTables()
        }else{
            
            
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
    
    func createTables() {
        
        for cls in self.modelClasses{
//            let tableName:String = "\(cls.class())"
//            if !dataBase.tableExists(tableName){
                let _ = self.createTableFor(cls: cls)
//            }
        }
    }
    func createTableFor(cls:AnyClass)->Bool{
        let sql:String = NSObject.sqlOfCreateTable(cls:cls)
        if sql.characters.count == 0 {
            return false 
        }
        dataBase.shouldCacheStatements = true
        return  dataBase.executeUpdate(sql , withArgumentsIn: [])
    }
    
    func clearAllTables(){
        for cls in self.modelClasses{
            let tableName:String = "\(cls.class())"
            if !dataBase.tableExists(tableName){
                let _ = self.clearTable(name: tableName)
            }
        }
    }
    func clearTable(name:String)->Bool{
        dataBase.shouldCacheStatements = true
        return dataBase.executeUpdate("delete from %@", withArgumentsIn: [name])
    }
    
    
    
}


