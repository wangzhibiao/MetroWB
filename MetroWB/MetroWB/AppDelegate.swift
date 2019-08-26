//
//  AppDelegate.swift
//  MetroWB
//
//  Created by 王小帅 on 2019/5/20.
//

import UIKit
//import SwiftEntryKit
import Bugly

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,WeiboSDKDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        // 检测线上crash
        Bugly.start(withAppId: "217782a099")
        
        // 监听网络状态变化
        MTNetWorkTools.shared.currentNetReachability()
        
        // 自动播放wifi下的视频
        if (UserDefaults.standard.value(forKey: ConstFile.auto_play_userdefault) as? Bool) == nil {
            UserDefaults.standard.set(false, forKey: ConstFile.auto_play_userdefault)
        }
        
        // 判断是有授权用户
        let uac = UserModel.getUserAccess()
        if uac.access_token == nil {
            // 未授权加载登录界面
            let root = BaseNavigationVC(rootViewController: LoginViewController())
            window?.rootViewController = root
        }else {
            // 加载主界面
            let root = BaseNavigationVC(rootViewController: MainViewController())
            window?.rootViewController = root
        }
        
        window?.makeKeyAndVisible()
        
        // 注册微博key
        WeiboSDK.enableDebugMode(true)
        WeiboSDK.registerApp(ConstFile.sina_app_key)
        
        return true
    }
    
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    
    // 授权微博结果 获取userid和token等信息
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if (response.isKind(of: WBAuthorizeResponse.self)) {
            
            let resp = response as! WBAuthorizeResponse
            if(resp.statusCode.rawValue == 0){// 授权成功
                
                // 获取用户授权信息 并保存到沙盒
               let uac = UserModel()
                uac.id = Int64(resp.userID)!
                uac.access_token = resp.accessToken
                uac.expires_in = resp.expirationDate.timeIntervalSinceNow
                uac.saveUserAccess()
                
                let root = BaseNavigationVC(rootViewController: MainViewController())
                
                UIApplication.shared.keyWindow?.rootViewController = root
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
                
            }else {
                MTAlertView().showInfo(msg: " 未能获取微博授权 ", inview: nil, duration: 2)
            }
        }
    }
    
    // 适配IOS10 以下两个回调必须有 否则就会在低版本中报错
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self as WeiboSDKDelegate)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self as WeiboSDKDelegate)
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

