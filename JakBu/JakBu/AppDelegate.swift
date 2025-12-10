//
//  AppDelegate.swift
//  JakBu
//
//  Created by 이지훈 on 12/10/25.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 알림 센터 delegate 설정 (포그라운드 알림을 위해 필수)
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        // 알림 권한 요청 및 매일 아침 8시 알림 설정
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                print("알림 설정 완료")
            }
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // 앱이 활성화될 때 배지 초기화
        NotificationManager.shared.clearBadge()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

