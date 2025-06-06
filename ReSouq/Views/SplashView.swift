import SwiftUI

struct SplashView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 1.0

    var body: some View {
        if isActive {
            if authViewModel.user != nil {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        } else {
            ZStack {
                Color(UIColor(red: 232/255, green: 225/255, blue: 210/255, alpha: 1))
                    .ignoresSafeArea()

                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 310, height: 300)
                    .scaleEffect(scaleEffect)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.5)) {
                            scaleEffect = 1.2
                        }
                    }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true
                }
            }
        }
    }
}

