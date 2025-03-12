//
//  ReSouqApp.swift
//  ReSouq
//

import SwiftUI
import FirebaseCore
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct ReSouqApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var cartViewModel = CartViewModel()
    @StateObject var orderViewModel = OrderViewModel()
    @StateObject var productViewModel = ProductViewModel()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var categoryViewModel = CategoryViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(authViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(orderViewModel)
                .environmentObject(productViewModel)
                .environmentObject(navigationManager)
                .environmentObject(categoryViewModel)
        }
    }
}
