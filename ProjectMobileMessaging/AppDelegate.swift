//
//  AppDelegate.swift
//  ProjectMobileMessaging
//
//  Created by NathanChou on 2023/11/30.
//

import UIKit
import MobileMessaging


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
#warning("require")
    // Sandbox
    var infobipKey: String = ""
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setupFirebase(application)
        
        SPAuthorizationManager.getNotificationAuthorization { status in
            // stauts: 0 拒絕
            // stauts: 1 允許
            // stauts: 2 未決定
            if status == 1 {
                MobileMessaging.withApplicationCode(self.infobipKey,
                                                    notificationType:MMUserNotificationType(options:[.alert, .sound]))?.start()
                SPInfobipAnalytics.setupUserAttributes()
            }
        }
        
        let viewController = ViewController()
        
        window?.rootViewController = viewController;
        window?.makeKeyAndVisible();
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        MobileMessaging.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)

//        completionHandler(.newData)
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        
        
        MobileMessaging.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken)
        MMInteractiveMessageAlertSettings.tintColor = .red
    }

}

extension AppDelegate {
    func setupFirebase(_ application: UIApplication) {
        
        SPAuthorizationManager.getNotificationAuthorization { status in
            if status == 2 {
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: { _, _ in
                            
                            MobileMessaging.withApplicationCode(self.infobipKey,
                                                                notificationType:MMUserNotificationType(options:[.alert, .badge, .sound]))?.start()
                            
                            SPInfobipAnalytics.setupUserAttributes()
                        }
                    )
                } else {
                    let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)

                    MobileMessaging.withApplicationCode(self.infobipKey,
                                                        notificationType:MMUserNotificationType(options:[.alert, .badge, .sound]))?.start()
                    
                    SPInfobipAnalytics.setupUserAttributes()
                }
            }
        }
        
        application.registerForRemoteNotifications()
//        UNUserNotificationCenter.current().delegate = self
    }
    
}

