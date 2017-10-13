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
