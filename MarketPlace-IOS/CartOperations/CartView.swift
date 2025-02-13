//
//  CartView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/13/25.
//

import SwiftUI
import Combine

struct TotalCartView: View {
    @StateObject private var viewModel = TotalCartViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            if viewModel.carts.isEmpty {
                ShimmeringStoreCardPlaceholder()
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.carts) { cart in
                            CartSectionView(cart: cart, onQuantityChange: viewModel.updateProductQuantity)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Shopping Cart")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(.systemGroupedBackground))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.themeRed) // Ensure back button is red
                        }
                    }
                }
            }
       
        }.navigationBarBackButtonHidden()
        .onAppear(perform: viewModel.loadCartData)
    }
}

struct CartSectionView: View {
    let cart: CartModel
    let onQuantityChange: (String, String, Int) -> Void
    @StateObject private var viewmodel = CartSectionViewModel()
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            StoreHeaderView(cart: cart)
            
            ForEach(cart.products) { product in
                ProductRowView(product: product, viewModel: .init(product: product, delegate: viewmodel))
            }
            
            Divider()
            
            SubtotalView(subtotal: cart.total_amount, tax: cart.tax_amount, total: cart.total_amount_with_tax)
            
            CheckoutButton(action: {
                print("Proceeding to checkout for \(cart.store_name)")
            })
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

class CartSectionViewModel: ObservableObject {

}
extension CartSectionViewModel: ProductListViewModelDelegate {
    func didtapOnEditButton(for product: EditProduct) {
        
    }
    
    func didtapOnDeleteButton(for product: Product) {
        
    }
    
    func didtapProduct(for product: Product) {
        
    }
    
}

struct StoreHeaderView: View {
    let cart: CartModel
    
    var body: some View {
        HStack(spacing: 12) {
            VStack {
                AsyncImageView(imageId: cart.store_image)
                    .frame(width: 60, height: 60)
            }.frame(width: 60, height: 60).cornerRadius(10)

            Text(cart.store_name)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}
struct ProductRowView: View {
    let product: Product
    @State var showLoginview: Bool = false
    var viewModel: ProductCellItemViewModel
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                AsyncImageView(imageId: product.imageids?.first ?? "")
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(product.product_name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(product.price.formattedPrice)")
                    .font(.subheadline)
                    .foregroundColor(.black)
                CartButtonView(showLoginview: $showLoginview, viewModel: viewModel)
            }
        }
    }
}

struct SubtotalView: View {
    let subtotal: Double
    let tax: Double
    let total: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Subtotal:")
                    .font(.subheadline)
                Spacer()
                Text(subtotal.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            HStack {
                Text("Tax:")
                    .font(.subheadline)
                Spacer()
                Text(tax.formattedPrice)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            HStack {
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text(total.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
    }
}

struct CheckoutButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Proceed to Checkout")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.themeRed)
                .cornerRadius(10)
        }
    }
}

struct CartModel: Identifiable, Codable {
    var id: String { cart_id }
    let cart_id: String
    let store_id: String
    let store_name: String
    let store_image: String
    var products: [Product]
    var total_amount: Double
    var tax_amount: Double
    var total_amount_with_tax: Double
}


struct AllCartProduct: Codable, Identifiable {
    var id: String { product_id }
    let product_id: String
    var quantity: Int
    let price: Double
    let product_name: String
    let imageids: [String]
}

extension Double {
    var formattedPrice: String {
        String(format: "$%.2f", self)
    }
}


class TotalCartViewModel: ObservableObject {
    @Published var carts: [CartModel] = []
    private var cancellables = Set<AnyCancellable>()

    func loadCartData() {
        // TODO: Implement API call to fetch cart data
        // For now, we'll use the provided mock data
        guard let customer_id = UserDetails.userId else { return  }
        
        let request = TotalCartRequest(customer_id: customer_id)

        NetworkManager.shared.performRequest(
            url: String.getCart(),
            method: .POST,
            payload: request,
            responseType: TotalCartsResponce.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                
                if case .failure(let error) = completion {
                    debugPrint("Cart creation failed:", error)
                }
            },
            receiveValue: { [weak self] response in
                DispatchQueue.main.async {
                    self?.carts = response.carts
                }
            }
        )
        .store(in: &cancellables)
     
    }
    
    func updateProductQuantity(cartId: String, productId: String, newQuantity: Int) {
        if let cartIndex = carts.firstIndex(where: { $0.cart_id == cartId }),
           let productIndex = carts[cartIndex].products.firstIndex(where: { $0.product_id == productId }) {
            carts[cartIndex].products[productIndex].quantity = newQuantity

            
        }
    }
    
}

struct TotalCartRequest: RequestBody {
    let customer_id: String
}

struct TotalCartsResponce: Codable {
    let carts: [CartModel]
}
