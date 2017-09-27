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
class Message: NSManagedObject {
    
    @NSManaged var msgID:Int32
    @NSManaged var senderID:String
    @NSManaged var msgContent:String
 
    
}
