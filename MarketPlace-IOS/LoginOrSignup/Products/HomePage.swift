//
//  HomePage.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import SwiftUI

struct HomePage: View {
    @State private var selectedTab = 0
    @StateObject var viewModel: DashBoardViewViewModel
    
    
    init(viewModel: DashBoardViewViewModel? = nil) {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.white
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        _viewModel = StateObject(wrappedValue: viewModel ?? DashBoardViewViewModel())

    }
    
    var body: some View {
            TabView(selection: $selectedTab) {
                NavigationView {
                    if UserDetails.isAppOwners {
                        ProductListView()
                    } else {
                        DashboardView(viewModel: viewModel)
                    }
                }
                .tabItem {
                    Image(selectedTab == 0 ? "homeselected" : "home")
                    Text("Home")
                }
                .tag(0)
                
                NavigationView {
                    OrderView()
                        .navigationTitle("Orders")
                }
                .tabItem {
                    Image(selectedTab == 1 ? "orderselected" : "orders")
                    Text("Orders")
                }
                .tag(1)
                
                NavigationView {
                    ProfileView()
                        .navigationTitle("Profile")
                }
                .tabItem {
                    Image(selectedTab == 2 ? "profileselected" : "profile")
                    Text("Profile")
                }
                .tag(2)
            }
            .accentColor(.themeRed)
        
    }

    @ViewBuilder
    private func navigationButton() -> some View {
        if UserDetails.isAppOwners {
            Button(action: {
                // Action to add a product
            }) {
                Image(systemName: "plus")
                    .foregroundColor(Color.themeRed)
            }
        } else {
            Button(action: {
                // Action to open cart
            }) {
                Image("cart")
                    .foregroundColor(Color.themeRed)
            }
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
