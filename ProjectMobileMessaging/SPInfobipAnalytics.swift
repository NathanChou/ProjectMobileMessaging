//
//  SPInfobipAnalytics.swift
//  ProjectMobileMessaging
//
//  Created by NathanChou on 2023/11/30.
//

import UIKit
import MobileMessaging


class SPInfobipAnalytics: NSObject {
    
    
    public class func setupUserAttributes() {

                
        var notificationStatus = "未設定"
        let locationStatus = "未設定"
        let userRole = "訪客"
        let userStatus = "無"

        let group = DispatchGroup()

        // stauts: 0 拒絕
        // stauts: 1 允許
        // stauts: 2 未決定

        group.enter()
        SPAuthorizationManager.getNotificationAuthorization { status in
            if status == 0 { notificationStatus = "已關閉" }
            if status == 1 { notificationStatus = "已開啟" }
            group.leave()
        }

        group.notify(queue: .main) {

#warning("require")
            let userName = ""
            
            let customAttributes = [
                "App產品別": "零卡" as NSString,
                "使用裝置": "iOS" as NSString,
                "App通知授權": notificationStatus as NSString,
                "App位置與定位服務授權": locationStatus as NSString,
                "App身分別": userRole as NSString,
                "App異常狀態值": userStatus as NSString,
                "登入狀態": "未登入" as NSString
            ]
            
            saveUserInfo(userName: userName, attributes: customAttributes)
        }

    }

    private class func saveUserInfo(userID: String? = "", userName: String? = "", attributes: [String: MMAttributeType]) {
        
#warning("require")
        let phoneNo = ""
        var newPhoneNo: String?
        if !phoneNo.isEmpty {
            newPhoneNo = phoneNo.replacingCharacters(in: ...phoneNo.startIndex, with: "886")
        }

        if let userIdentity = MMUserIdentity(phones: (newPhoneNo != nil) ? [newPhoneNo!] : nil, emails: nil, externalUserId: nil) {
            let userAttributes = MMUserAttributes(firstName: userName, middleName: nil, lastName: nil, tags: nil,
                                                  gender: nil, birthday: nil, customAttributes: attributes)

            MobileMessaging.personalize(withUserIdentity: userIdentity, userAttributes: userAttributes) { error in
                if (error != nil) {
                    print(error as Any)
                }
            }
        }
    }
}

