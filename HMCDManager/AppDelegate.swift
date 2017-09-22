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
       
        HMCDManager.shared.coreDataModelNames.append("first")
        HMCDManager.shared.coreDataModelNames.append("second")
        HMCDManager.shared.userDBName = ""///"user3"
        
        APPInfo.runTest()
        
//        if let app:APPInfo = APPInfo.newObj() as? APPInfo{
//
//            app.appid = Int16(arc4random()%UInt32(1000))
//            app.name =  "defailt  name"
//            app.db_update(completion: { (error) in
//                if error == nil  {
//                }else{
//                    print("add group name failure:\(error!)")
//                }
//            })
//
//            APPInfo.db_query(offset: 0, limitCount: 0, success: { (objs ) in
//                for obj in objs{
//                    print(obj.value(forKey: "appid")!)
//                }
//            }, failure: { (error ) in
//                print(error)
//            })
//        }
        
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

