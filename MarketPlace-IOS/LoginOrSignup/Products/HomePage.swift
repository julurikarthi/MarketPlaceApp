//
//  HomePage.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import SwiftUI

struct HomePage: View {
    @State private var selectedTab = 0


    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground() // Ensures it's not transparent
        tabBarAppearance.backgroundColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Background color applied globally
            
            TabView(selection: $selectedTab) {
                ProductListView()
                    .tabItem {
                        Image(selectedTab == 0 ? "homeselected" : "home")
                        Text("Home")
                    }
                    .tag(0)

                ProfileView()
                    .tabItem {
                        Image(selectedTab == 1 ? "orderselected" : "orders")
                        Text("Orders")
                    }
                    .tag(1)

                ProfileView()
                    .tabItem {
                        Image(selectedTab == 2 ? "profileselected" : "profile")
                        Text("Profile")
                    }
                    .tag(2)
            }
            .accentColor(.themeRed)
        }

     
    }
}

struct HomeView: View {
    var body: some View {
        Text("Home Screen")
    }
}

struct SearchView: View {
    var body: some View {
        Text("Search Screen")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile Screen")
    }
}


#Preview {
    HomePage()
}
