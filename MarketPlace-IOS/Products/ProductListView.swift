//
//  ProductListView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/24/25.
//

import SwiftUI

struct ProductListView: View {
  
    @State private var showAddProductView: Bool = false
    @State private var showCreateProductView: Bool = false
    @State private var test: Bool = false
    @Environment(\.presentationMode) var presentationMode // For manual back action
    @StateObject private var viewModel = ProductListViewModel()
    let columns = [
          GridItem(.flexible()),
          GridItem(.flexible())
      ]
    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.categories.isEmpty  {
                    ScrollView {
                        CategoriesTabBarView(tabs: viewModel.categories, onTabSelection: { category in
                            Task {
                                await viewModel.getAllProductbyStore(category_id: category.categoryID)
                            }
                        })
                        if $viewModel.storeProductsbyCategories.products.isEmpty {
                            addtoProductView()
                        } else {
                            productsView()
                        }
                    }
                } else {
                    if viewModel.categories.isEmpty {
                        addtoProductView()
                    }
                }
                
                NavigationLink(
                    "", destination: CreateProductView()
                        .navigationBarBackButtonHidden(true),
                    isActive: $showAddProductView)
                
                NavigationLink(
                    "", destination: CreateStoreView()
                        .navigationBarBackButtonHidden(true),
                    isActive: $showCreateProductView)
            }.navigationTitle("Products")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) { // Add a button on the right side
                        Button(action: {
                            // Action to add a product
                            self.showAddProductView = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(Color.themeRed)
                        }
                    }
                }
        }.task {
            let isCategoriesFetched = await viewModel.getstoreCategories()
               if isCategoriesFetched {
                   await viewModel.getAllProductbyStore()
               }
        }.loadingIndicator(isLoading: $viewModel.showProgressIndicator)
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
                showAddProductView = true
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
                ProductCellItem(viewModel: ProductCellItemViewModel(product: product.wrappedValue))
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
