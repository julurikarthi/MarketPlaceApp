//
//  MarketPlace_IOSApp.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI
import GooglePlaces

@main
struct MarketPlace_IOSApp: App {
    @StateObject var cartViewModel = CartViewModel()
    @ObservedObject var dashboardViewModel = DashBoardViewViewModel()
    @State private var isLoading = true
    @AppStorage("state") var state: String = ""
    @AppStorage("pincode") var pincode: String = ""
    init() {
            GMSPlacesClient.provideAPIKey("AIzaSyCilh2e-XLRrdwSM0hHfcGMewbYbZfcmHU")
        }
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)

                if UserDetails.isAppOwners {
                    if UserDetails.isLoggedIn {
                        if UserDetails.storeId != nil {
                            HomePage()
                        } else {
                            CreateStoreView()
                        }
                    } else {
                        LoginView()
                    }
                } else {
                    if isLoading {
                        SplashScreenView()
                            .onAppear {
                                loadDashboardData()
                            }
                    } else {
                        DashboardView(viewModel: dashboardViewModel)
                            .environmentObject(cartViewModel)
                    }
                }

                
            }
        }
    }
    
    private func loadDashboardData() {
        if !state.isEmpty, !pincode.isEmpty {
            dashboardViewModel.getDashboardData(pincode: pincode, state: state) { status, cartItems in
                if status {
                    DispatchQueue.main.async {
                        cartViewModel.cartItemCount = cartItems
                        isLoading = false
                    }
                }
            }
        } else {
            dashboardViewModel.getCurrentLocation { _ in
                dashboardViewModel.getDashboardData(pincode: dashboardViewModel.pincode ?? "", state: dashboardViewModel.state ?? "") { status, cartItems in
                    if status {
                        DispatchQueue.main.async {
                            cartViewModel.cartItemCount = cartItems
                            isLoading = false
                        }
                    }
                }
            }
        }
    }

}



extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct CartNavigationView<Content: View>: View {
    let title: String
    let content: Content
    @EnvironmentObject var cartViewModel: CartViewModel
    @State private var showLoginView = false
    @State private var showtotalCartView = false
    @State private var showAddProductView = false

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack {
                            Button(action: {
                                if UserDetails.isLoggedIn {
                                    // Navigate to TotalCartView
                                    if UserDetails.isAppOwners  {
                                        showAddProductView = true
                                    } else {
                                        showtotalCartView = true
                                    }
                                    
                                } else {
                                    // Show login view
                                    showLoginView = true
                                }
                            }) {
                                if UserDetails.isAppOwners {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 14, height: 14)
                                        .padding(.trailing, 4)
                                        .foregroundColor(.red)
                                } else {
                                    Image(UserDetails.isAppOwners ? "plus" : "shopping-cart")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .padding(.trailing, 4)
                                }
                                
                            }
                            .fullScreenCover(isPresented: $showLoginView) {
                                LoginView()
                            }
                            if !UserDetails.isAppOwners {
                                if cartViewModel.cartItemCount > 0 {
                                    Text("\(cartViewModel.cartItemCount)")
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                            
                        }
                    }
                  
                }
            NavigationLink(
                destination: TotalCartView()
                    .navigationBarBackButtonHidden(true),
                isActive: $showtotalCartView
            ) {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(
                destination: CreateProductView(editProduct: .constant(nil))
                    .navigationBarBackButtonHidden(true),
                isActive: $showAddProductView
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func navigateToCart() -> some View {
        NavigationLink(destination: TotalCartView()) {
            EmptyView()
        }
    }
}


