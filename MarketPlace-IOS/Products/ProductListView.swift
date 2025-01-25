//
//  ProductListView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/24/25.
//

import SwiftUI

struct ProductListView: View {
    @State private var products: [String] = [] // List of products
    @State private var showAddProductView: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if products.isEmpty {
                    // When there are no products
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
                } else {
                    // When there are products
                    List {
                        ForEach(products, id: \.self) { product in
                            Text(product)
                        }
                    }
                }
            }
            .navigationTitle("Products")
            .sheet(isPresented: $showAddProductView) {
//                AddProductView { newProduct in
//                    products.append(newProduct)
//                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView()
    }
}


extension Color {
    static let themeRed = Color(hex: "#D91300")
}
