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

struct ProductCellItem: View {
  
    @StateObject var viewModel: ProductCellItemViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image Carousel
            ZStack(alignment: .bottomTrailing) {
                TabView {
                    ForEach(viewModel.productImages, id: \.self) { image in
                        VStack {
                            Image(uiImage: image)
                                .scaledToFill()
                                .clipped()
                        }.frame(width: 150, height: 200)
                       
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 200)
                
                AddToCartView().padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
                  
            }
            
            PriceView(price: viewModel.productPrice)
                .padding(EdgeInsets(top: 0, leading: -13, bottom: 0, trailing: 0))

            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.productTitle)
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: 0))

               
                Text(viewModel.description)
                    .font(.subheadline)
                    .foregroundColor(Color.subtitleGray)
                    .lineLimit(2)
                    .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: 0))

                if UserDetails.store_type == nil {
                    Text("In stock: \(viewModel.stock)")
                        .font(.subheadline)
                        .foregroundColor(Color.subtitleGray)
                        .padding(EdgeInsets(top: 0, leading: -20, bottom: 0, trailing: 0))
                }
                if viewModel.stockCount > 50 {
                    Text("Many in stock")
                        .padding(5)
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(Color(hex: "#02832D"))
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(2)
                        .padding(EdgeInsets(top: 3, leading: -23, bottom: 0, trailing: 0))

                }
              
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.white).task {
            await viewModel.downloadproductImages()
        }
    }
}

struct AddToCartView: View {
    @State var itemCount: Int = 0

    var body: some View {
        if itemCount == 0 {
            Button(action: {
                itemCount += 1
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(Color.white))
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }.padding([.trailing, .bottom], 5)
        } else {
            VStack {
                HStack(spacing: 16) {
                    Button(action: {
                        if itemCount > 0 { itemCount -= 1 }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.white))
                    }
                    
                    Text("\(itemCount)")
                        .font(.headline)
                    
                    Button(action: {
                        itemCount += 1
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.white))
                    }
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }.padding([.trailing, .bottom], 5)
        }
    }
}

struct PriceView: View {
    var price: Double = 0

    var body: some View {
        HStack(alignment: .center) {
            Text("$")
                .foregroundColor(.black)
                .offset(x: 8, y: -2)
                .font(.system(size: 12, weight: .bold, design: .default))

            Text(String(format: "%.0f", price))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .font(.system(size: 15, weight: .bold, design: .default))

            let cents = (price * 100).truncatingRemainder(dividingBy: 100)
            if cents > 0 {
                Text(String(format: "%02d", Int(cents)))
                    .offset(x: -8, y: -2)
                    .font(.system(size: 12, weight: .bold, design: .default))
                
            }
        }
    }
}
