//
//  AppDelegate.swift
//  HMCDManager
//
//  Created by HuangZhongQing on 2017/9/21.
//  Copyright © 2017年 HuangZhongQing. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        APPInfo.runTest()
        
        
        HMCDManager.shared.userDBName = ""
        
//        let testobj = Message.newNotInertObj() as! Message
//        debugPrint(  testobj.getThePrimaryKeyName(),testobj.getThePrimaryKeyName().characters.count )
        
//        if let message:Message =  NSObject.newObjFor(subCls: Message.classForCoder()) as? Message{
//            message.setobj(str: "fwffsdfsdfsdfsdfs")
//            
//            print("new message obj :\(message)  \(message.getobj())")
//        }
        
        HMDBManager.shared.modelClasses = [Message.classForCoder(),TestModel.classForCoder(),Model2.classForCoder()]
        HMDBManager.shared.openDB()
        
        let testModel = TestModel.init()
        testModel.objID = "66"
        testModel.message = "63222"
        testModel.date3 = 44
        testModel.date1 = Date().addingTimeInterval(-4242342)
        testModel.info = ["name":"ff","id2":99905]
        testModel.extraObj = ["test obj",223,["obj2",42342]]
        testModel.datas = "42342342423".data(using: .utf8)
        testModel.url = URL.init(string: "http://baidu.com")
        testModel.dbSave { (success ) in
             debugPrint("testmodel save : \(success)  ")
        }
//        testModel.dbDelete { (success ) in
//            debugPrint("testmodel delete : \(success)")
//        }
        
//        let mm:Model2 = Model2.init(primaryValue:67,createIfNoneExist:false)
//        mm.objID = "f3r32r236666"
//        
//        mm.dbUpdate { (succcess) in
//             debugPrint("mm dbUpdate : \(succcess)")
//        }
//        mm.dbAdd { (succcess) in
//            debugPrint("mm db add : \(succcess)")
//        }
        
        TestModel.dbQuery(whereStr: nil , orderFields: "objID asc" , offset: 0, limit: 0, args: []) { (objs , error ) in
            debugPrint("TestModel query resluts :\(objs.count) \(error?.localizedDescription ?? "")")
            for obj in objs {
                if let model = obj as? TestModel{
                    debugPrint(model.objID,model.message,model.date3,model.date1,String.init(data: model.datas ?? Data() , encoding: .utf8),model.url )
                }
            }
        }
        Model2.dbQuery(whereStr: nil , orderFields: nil , offset: 0, limit: 0, args: []) { (objs , error ) in
            debugPrint("Model2 query resluts :\(objs.count) \(error?.localizedDescription ?? "")")
            for obj in objs {
                if let model = obj as? Model2{
                    debugPrint(model.defaultPK,model.objID)
                }
            }
        }
        let rootVC = UINavigationController.init(rootViewController: DemoTableViewController.init())
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

