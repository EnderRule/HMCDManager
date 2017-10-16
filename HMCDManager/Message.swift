//
//  Message.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit
import CoreData

@objc(Message)
class Message: NSManagedObject,HMDBModelDelegate {
    
    @NSManaged var msgID:Int32
    @NSManaged var senderID:String
    @NSManaged var msgContent:String
 
    var fff:Int = 333
    
    let primaryKeyName:String = "msgID"
    
    override func didTurnIntoFault() {
        
    }
    
    func dbFields() -> [String] {
        return ["msgID","senderID","msgContent"]
    }
    
    func dbPrimaryKey() -> String? {
        return "msgID"
    }
    
   
    
}

class TestModel:NSObject,HMDBModelDelegate{
 
    var objID:String = ""
    var message:String = ""
    var date3:Int = 3 // = NSDate()
    var date1:Date = Date.init()
    
    var info:[String:Any] = [:]
    var extraObj:[Any] = []
    var datas:Data?
    var url:URL?
    func dbFields() -> [String] {
        return ["objID","message","date3","date1","info","extraObj","datas","url"]
    }
    func dbPrimaryKey() -> String? {
        return "objID"
    }
    
//    func dbDeleteFields()->[String]{
//        return []
//    }
}

class Model2:NSObject,HMDBModelDelegate
{
    var objID:String = ""
    
    func dbFields() -> [String] {
        return ["objID"]
    }
    func dbPrimaryKey() -> String? {
        return nil
    }
}
