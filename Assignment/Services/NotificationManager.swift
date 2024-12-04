//
//  NotificationManager.swift
//  Assignment
//
//  Created by Atul Upadhyay on 04/12/24.
//


import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
