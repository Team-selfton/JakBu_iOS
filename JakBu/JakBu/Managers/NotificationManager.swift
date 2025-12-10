import UIKit
import UserNotifications

class NotificationManager: NSObject {

    static let shared = NotificationManager()

    private override init() {
        super.init()
    }

    // MARK: - Setup

    /// 알림 권한 요청 및 초기 설정
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error.localizedDescription)")
                completion(false)
                return
            }

            if granted {
                print("알림 권한 허용됨")
                self.scheduleDailyNotification()
            } else {
                print("알림 권한 거부됨")
            }

            completion(granted)
        }
    }

    /// 알림 권한 상태 확인
    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            completion(isAuthorized)
        }
    }

    // MARK: - Schedule Notifications

    /// 테스트용 즉시 알림 (5초 후)
    func sendTestNotification() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "JakBu 테스트"
        content.body = "알림이 정상적으로 작동합니다! 💪"
        content.sound = .default
        content.badge = 1

        // 5초 후에 알림 발송
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("테스트 알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("5초 후 테스트 알림이 발송됩니다.")
            }
        }
    }

    /// 매일 아침 8시 알림 예약
    func scheduleDailyNotification() {
        let center = UNUserNotificationCenter.current()

        // 기존 알림 제거
        center.removePendingNotificationRequests(withIdentifiers: ["daily-morning-notification"])

        // 알림 콘텐츠 설정
        let content = UNMutableNotificationContent()
        content.title = "JakBu"
        content.body = "오늘의 할 일을 확인하고 작심삼일을 부숴봐요! 💪"
        content.sound = .default
        content.badge = 1

        // 매일 아침 8시로 설정
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // 알림 요청 생성
        let request = UNNotificationRequest(
            identifier: "daily-morning-notification",
            content: content,
            trigger: trigger
        )

        // 알림 예약
        center.add(request) { error in
            if let error = error {
                print("알림 예약 실패: \(error.localizedDescription)")
            } else {
                print("매일 아침 8시 알림이 예약되었습니다.")
            }
        }
    }

    /// 예약된 알림 확인 (디버깅용)
    func checkPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            print("예약된 알림 개수: \(requests.count)")
            for request in requests {
                print("- ID: \(request.identifier)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  시간: \(trigger.dateComponents)")
                }
            }
        }
    }

    /// 모든 알림 제거
    func removeAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    /// 배지 숫자 초기화
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {

    /// 앱이 포그라운드에 있을 때 알림을 받으면 호출
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("포그라운드 알림 수신: \(notification.request.content.title)")
        // 앱이 실행 중일 때도 알림을 표시 (배너, 소리, 배지 모두 표시)
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    /// 사용자가 알림을 탭했을 때 호출
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // 알림을 탭했을 때의 동작 (필요시 특정 화면으로 이동 등)
        print("알림 탭됨: \(response.notification.request.identifier)")

        // 배지 초기화
        clearBadge()

        completionHandler()
    }
}
