//
//  AppDelegate.swift
//  ChatSDKSwift
//
//  Created by Benjamin Smiley-andrews on 07/03/2016.
//  Copyright © 2016 deluge. All rights reserved.
//

import UIKit
import ChatSDK

@UIApplicationMain
/* Two Factor Auth */
//class AppDelegate: UIResponder, UIApplicationDelegate, BTwoFactorAuthDelegate {
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    /* Two Factor Auth */
    //var verifyViewController:BVerifyViewController?;

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let config = BConfiguration.init();
        config.rootPath! = "test"
        config.allowUsersToCreatePublicChats = false
        config.googleMapsApiKey = "AIzaSyCwwtZrlY9Rl8paM0R6iDNBEit_iexQ1aE"
        config.clearDatabaseWhenDataVersionChanges = true
        config.clearDataWhenRootPathChanges = true;
        config.databaseVersion = "2"

        BChatSDK.initialize(config, app: application, options: launchOptions)
        NM.moderation().on()

        let block = BChatSDK.auth()?.authenticateWithCachedToken()?.thenOnMain

        _ = block?({(result: Any?) -> Any? in
            
            BChatSDK.shared()?.interfaceManager = CustomAdapter()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = UINavigationController(rootViewController: (BChatSDK.ui()?.privateThreadsViewController())!)
            self.window?.makeKeyAndVisible()
            
            return result
        }, {(error: Error?) -> Any? in
            
            
            print(error)
            
            return error
        })

//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        self.window?.rootViewController = BChatSDK.ui()?.appTabBarViewController()
//        self.window?.makeKeyAndVisible()
        

        
      
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        BChatSDK.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        BChatSDK.application(application, didReceiveRemoteNotification: userInfo)
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return BChatSDK.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return BChatSDK.application(app, open: url, options: options)
    }

}
