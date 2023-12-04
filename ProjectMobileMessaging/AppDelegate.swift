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
        
        //enable logging for debug purposes
        MobileMessaging.logger = MMDefaultLogger()
        
        MobileMessaging.withApplicationCode(self.infobipKey,
                                            notificationType: MMUserNotificationType(options:[.alert, .badge, .sound]))?
        // If Registration is done separately, then this method needs to be called
            .withoutRegisteringForRemoteNotifications()
        
        // It's not necessary needs to be called in your case, but without it if depersonalization was called MobileMessaging SDK will unregister from remote notifications
            .withoutUnregisteringForRemoteNotifications()
// You may need it in case if another provider is setting UserNotificationCenter delegate, but handling of the notification Tap won't work inside of the MobileMessaging SDK, so you'll need in this case to handle it yourself, all fields from MTMessage you can find in the github - https://github.com/infobip/mobile-messaging-sdk-ios/blob/9ca0b32c392a70c31de6dbf72e098bf30e0ca05a/Classes/MobileMessaging/Core/Message/MTMessage.swift#L11
//            .withoutOverridingNotificationCenterDelegate()
            .start()
        
                
        window = UIWindow(frame: UIScreen.main.bounds)
        
        setupFirebase(application)
        
        SPAuthorizationManager.getNotificationAuthorization { status in
            // stauts: 0 拒絕
            // stauts: 1 允許
            // stauts: 2 未決定
            if status == 1 {
                
// 1 - Too late to call .start, this might be one of the reasons why notificationTapped event wasn't handled
// 2 - Too many calls of .start, better call it only once or it might delay the SDK cause it'll restart and start again if parameters are different

//                MobileMessaging.withApplicationCode(self.infobipKey,
//                                                    notificationType:MMUserNotificationType(options:[.alert, .sound]))?.start()
// 3 - All manipulations with user attributes or personalization needs to be done after we got MMNotificationRegistrationUpdated event
// https://github.com/infobip/mobile-messaging-sdk-ios/wiki/Personalization-implementation-for-mobile-apps-with-authorization
//                SPInfobipAnalytics.setupUserAttributes()
            }
        }
        
        let viewController = ViewController()
        
        window?.rootViewController = viewController;
        window?.makeKeyAndVisible();
        
        
        // The further logic is from this doc https://github.com/infobip/mobile-messaging-sdk-ios/wiki/Personalization-implementation-for-mobile-apps-with-authorization
        // Subscribe to the MMNotificationRegistrationUpdated event, it's sent when MobileMessaging SDK gets connected to Infobip's backend (push registration ID is generated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleRegistrationUpdatedNotification(_:)), name: NSNotification.Name(rawValue: MMNotificationRegistrationUpdated), object: nil)

        // If it's not the first start and push registration ID already was saved in the MobileMessaging SDK
        if !(MobileMessaging.getInstallation()?.pushRegistrationId?.isEmpty ?? true) {
            SPInfobipAnalytics.setupUserAttributes()
        }
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if MM_MTMessage.isCorrectPayload(userInfo) {
            MobileMessaging.didReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
        } else {
            // Other push vendors might have their code here and handle a remote notification as well.
            // completionHandler needs to be called only once.
            completionHandler(.noData)
        }
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
    
    //Handling of the MobileMessaging events
    @objc func handleRegistrationUpdatedNotification(_ notification: NSNotification) {
        SPInfobipAnalytics.setupUserAttributes()
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
                            
// 1 - Too late to call .start, this might be one of the reasons why notificationTapped event wasn't handled
//                            MobileMessaging.withApplicationCode(self.infobipKey,
//                                                                notificationType:MMUserNotificationType(options:[.alert, .badge, .sound]))?.start()
                            
// 3 - All manipulations with user attributes or personalization needs to be done after we got MMNotificationRegistrationUpdated event
// https://github.com/infobip/mobile-messaging-sdk-ios/wiki/Personalization-implementation-for-mobile-apps-with-authorization
//                            SPInfobipAnalytics.setupUserAttributes()
                        }
                    )
                } else {
                    let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    application.registerUserNotificationSettings(settings)

// 1 - Too late to call .start, this might be one of the reasons why notificationTapped event wasn't handled
//                    MobileMessaging.withApplicationCode(self.infobipKey,
//                                                        notificationType:MMUserNotificationType(options:[.alert, .badge, .sound]))?.start()
                    
// 3 - All manipulations with user attributes or personalization needs to be done after we got MMNotificationRegistrationUpdated event
//                    SPInfobipAnalytics.setupUserAttributes()
                }
            }
        }
        
        application.registerForRemoteNotifications()
//        UNUserNotificationCenter.current().delegate = self
    }
    
}

