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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
class AppDelegate: NSObject, UIApplicationDelegate {
    static var asiuqzoptqxbt = UIInterfaceOrientationMask.portrait {
        didSet {
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: asiuqzoptqxbt))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if asiuqzoptqxbt == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.asiuqzoptqxbt
    }
}


