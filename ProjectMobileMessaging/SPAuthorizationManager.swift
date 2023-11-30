//
//  SPAuthorizationManager.swift
//  ProjectMobileMessaging
//
//  Created by NathanChou on 2023/11/30.
//

import UIKit

@objcMembers class SPAuthorizationManager: NSObject {

    // stauts: 0 拒絕
    // stauts: 1 允許
    // stauts: 2 未決定
    
    public class func getNotificationAuthorization(completion: @escaping (Int) -> ()) {
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
 
            switch settings.authorizationStatus {
                
            case .notDetermined:
                completion(2)
            case .denied:
                completion(0)
            case .authorized:
                completion(1)
            case .provisional:
                completion(1)
            case .ephemeral:
                completion(1)
            @unknown default:
                completion(0)
            }
        }
    }
    

    public class func requestNotificationAuthorization(completion: @escaping (Int) -> ()) {

        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound, .badge]) { bool, error in
            if bool {
                print("使用者同意")
                completion(1)
            } else {
                print("使用者拒絕")
                completion(0)
            }
        }
    }
    
}

