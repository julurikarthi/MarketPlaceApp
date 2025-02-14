//
//  ProductListView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/24/25.
//

import SwiftUI

struct ProductListView: View {
  
    @State private var showCreateProductView: Bool = false
    var isCustomer: Bool = false
    @Environment(\.presentationMode) var presentationMode // For manual back action
    @StateObject private var viewModel = ProductListViewModel()
    @StateObject private var categoryViewModel = CategoriesTabBarViewModel()
    @State var showLoginview: Bool = false

    init(isCustomer: Bool = false) {
        self.isCustomer = isCustomer
    }
    
    let columns = [
          GridItem(.flexible())
      ]
    var body: some View {
        VStack {
            if !viewModel.categories.isEmpty  {
                ScrollView {
                    CategoriesTabBarView(tabs: viewModel.categories, onTabSelection: { category in
                        viewModel.selectedCategory = category
                        viewModel.getAllProductbyStore(category_id: category.categoryID, isCustomer: isCustomer)
                    }, viewModel: categoryViewModel)
                    if $viewModel.storeProductsbyCategories.products.isEmpty {
                        addtoProductView()
                    } else {
                        productsView()
                    }
                }.sheet(isPresented: $showLoginview) {
                    LoginView()
                }
            } else {
                if UserDetails.isAppOwners, viewModel.categories.isEmpty {
                    addtoProductView().frame(maxWidth: .infinity, maxHeight: .infinity).offset(y: 150)
                }
            }
            NavigationLink(
                destination: CreateProductView(editProduct: $viewModel.editProduct)
                    .navigationBarBackButtonHidden(true),
                isActive: $viewModel.showAddProductView
            ) {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(
                destination: CreateStoreView()
                    .navigationBarBackButtonHidden(true),
                isActive: $showCreateProductView
            ) {
                EmptyView()
            }
            .hidden()
            
        }.background(.white).navigationBarBackButtonHidden()
            .loadingIndicator(isLoading: $viewModel.showProgressIndicator)
            .toolbar {
                if isCustomer {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .onAppear {
                if viewModel.categories.isEmpty {
                    viewModel.getstoreCategories(isCustomer: isCustomer)
                }
                /// TODO: asking permission ar right place
                //                UserDetails.requestCameraPermission()
                //                UserDetails.requestPhotoLibraryPermission()
            }
        
    }
    
    func addtoProductView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.plus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            
            Text("No Products Available")
                .font(.headline)
                .foregroundColor(.gray)
            
            Button(action: {
                viewModel.showAddProductView = true
            }) {
                Text("Add Product")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    func productsView() -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array($viewModel.storeProductsbyCategories.products.enumerated()), id: \.offset) { index, product in
                ProductCellItem(viewModel: ProductCellItemViewModel(product: product.wrappedValue, delegate: viewModel, selectedCategory: viewModel.selectedCategory), showLoginview: $showLoginview).id(product.product_id.wrappedValue)
            }
        }
        .padding()
    }
}



struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}


extension Color {
    static let themeRed = Color(hex: "#D91300")
    static let subtitleGray = Color(hex: "#606060")
}
