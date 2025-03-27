//
//  UskwysniwasApp.swift
//  Uskwysniwas
//
//  Created by dsm 5e on 24.03.2025.
//

import SwiftUI
import UserNotifications

@main
struct UskwysniwasApp: App {
    @StateObject private var gameManager = GameManager()
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
    
    init() {
        // Запрос разрешения на отправку уведомлений
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Ошибка запроса разрешения на уведомления: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if onboardingCompleted {
                MainTabView()
                    .preferredColorScheme(.dark)
                    .environmentObject(gameManager)
            } else {
                OnboardingView(onboardingCompleted: $onboardingCompleted)
                    .environmentObject(gameManager)
            }
        }
    }
}
