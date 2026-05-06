//
//  Proyecto_ReportesApp.swift
//  Proyecto Reportes
//
//  Created by Alumno on 25/03/26.
//

import SwiftUI
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    // Mostrar notificaciones incluso con la app en primer plano
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

@main
struct Proyecto_ReportesApp: App {

    private let notificationDelegate = NotificationDelegate()

    init() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error al solicitar permisos de notificación: \(error.localizedDescription)")
            } else {
                print("Permiso de notificaciones: \(granted ? "concedido" : "denegado")")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
