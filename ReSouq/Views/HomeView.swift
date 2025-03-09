//
//  HomeView.swift
//  ReSouq
//
//  Created by Al Maha Al Jabor on 09/03/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {

                    Spacer()
                }

                VStack {
                    Spacer()
                }
                .ignoresSafeArea(.all, edges: .bottom) 
            }
        }
    }
}
