//
//  ReSouqApp.swift
//  ReSouq
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseMessaging
import FirebaseAuth
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()

        // Set Messaging delegate
        Messaging.messaging().delegate = self
        
        // Request permission for notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        // Fix: Declare `providerFactory` first, then assign it based on the platform
        let providerFactory: AppCheckProviderFactory

        #if targetEnvironment(simulator)
        print("Using Debug App Check for Simulator")
        providerFactory = AppCheckDebugProviderFactory()
        #else
        print("Using DeviceCheck for Real Device")
        providerFactory = DeviceCheckProviderFactory() 
        #endif

        AppCheck.setAppCheckProviderFactory(providerFactory)

        return true
            
    }

    // MARK: - Handle Firebase Messaging Token
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "No Token")")
    }

    // MARK: - Handle Incoming Remote Notifications (Required for OTP)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }

        // Handle other notifications if needed
        completionHandler(.newData)
    }
}

@main
struct ReSouqApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var authViewModel = AuthViewModel()
    @StateObject var cartViewModel = CartViewModel()
    @StateObject var orderViewModel = OrderViewModel()
    @StateObject var productViewModel = ProductViewModel()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var categoryViewModel = CategoryViewModel()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(orderViewModel)
                .environmentObject(productViewModel)
                .environmentObject(navigationManager)
                .environmentObject(categoryViewModel)
        }
    }
}

