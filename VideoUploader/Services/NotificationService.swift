//
//  NotificationService.swift
//  VideoUploader
//
//  Created by Elena Kim on 1/5/24.
//

import UserNotifications

final class NotificationService {
    static func sendPush(body: String) {
        let content = UNMutableNotificationContent()
        content.title = "Youtube uploader"
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling local notification: \(error)")
            } else {
                print("Local notification scheduled successfully")
            }
        }
    }
}
