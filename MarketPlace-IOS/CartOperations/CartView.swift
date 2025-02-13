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
    
    var body: some View {
        NavigationView {
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
                .background(Color(.systemGroupedBackground))
            }
       
        }
        .onAppear(perform: viewModel.loadCartData)
    }
}

struct CartSectionView: View {
    let cart: CartModel
    let onQuantityChange: (String, String, Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            StoreHeaderView(cart: cart)
            
            ForEach(cart.products) { product in
                ProductRowView(product: product, onQuantityChange: { newQuantity in
                    onQuantityChange(cart.cart_id, product.product_id, newQuantity)
                })
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

struct StoreHeaderView: View {
    let cart: CartModel
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: cart.store_image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
            }
            
            Text(cart.store_name)
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}
struct ProductRowView: View {
    let product: AllCartProduct
    let onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 80, height: 80)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(product.product_name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text("\(product.price)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                QuantityStepper(quantity: product.quantity, onChange: onQuantityChange)
            }
        }
    }
}

struct QuantityStepper: View {
    let quantity: Int
    let onChange: (Int) -> Void
    
    var body: some View {
        HStack {
            Button(action: { if quantity > 1 { onChange(quantity - 1) } }) {
                Image(systemName: "minus.circle.fill")
            }
            .disabled(quantity <= 1)
            
            Text("\(quantity)")
                .frame(width: 30)
            
            Button(action: { onChange(quantity + 1) }) {
                Image(systemName: "plus.circle.fill")
            }
        }
        .font(.system(size: 20))
        .foregroundColor(.blue)
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
            }
            HStack {
                Text("Tax:")
                    .font(.subheadline)
                Spacer()
                Text(tax.formattedPrice)
                    .font(.subheadline)
            }
            HStack {
                Text("Total:")
                    .font(.headline)
                Spacer()
                Text(total.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.blue)
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
                .background(Color.blue)
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
    var products: [AllCartProduct]
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
