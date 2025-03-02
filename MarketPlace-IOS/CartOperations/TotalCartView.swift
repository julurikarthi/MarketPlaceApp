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
            VStack {
                if let error = viewModel.error, viewModel.carts.isEmpty {
                    CartEmptyView(errorMessage: error)
                } else if viewModel.carts.isEmpty {
                    ShimmeringStoreCardPlaceholder()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.carts) { cart in
                                CartSectionView(viewmodel: .init(cart: cart))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.themeRed)
                            Text("Back")
                                .foregroundColor(.themeRed)
                        }
                    }
                }
            }
        }
        .onAppear(perform: viewModel.loadCartData)
    }
}

// MARK: - Cart Empty View
struct CartEmptyView: View {
    let errorMessage: String

    var body: some View {
        VStack {
            Image(systemName: "cart.badge.minus")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 10)

            Button(action: {
                // Action to retry or navigate elsewhere
            }) {
                Text("Continue Shopping")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.themeRed)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .padding(.horizontal, 40).hidden()
        }
        .padding()
    }
}


struct CartSectionView: View {
    @StateObject var viewmodel: CartSectionViewModel
    @State private var selectedServiceType: String? = nil
    
    init(viewmodel: CartSectionViewModel, selectedServiceType: String? = nil) {
        self._viewmodel = StateObject(wrappedValue:viewmodel)
        self.selectedServiceType = selectedServiceType
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            StoreHeaderView(cart: viewmodel.cart)
            
            ForEach(viewmodel.cart.products) { product in
                ProductRowView(product: product,
                               viewModel: .init(store_id: product.store_id,
                                                product_id: product.product_id,
                                                variant_type: product.variant_type,
                                                itemCount: product.quantity),
                               cart: viewmodel.cart,
                               cartPubliser: viewmodel.cartPubliser)
            }
            
            Divider()
            
            SubtotalView(subtotal: viewmodel.total_amount, tax: viewmodel.tax_amount, total: viewmodel.total_amount_with_tax)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Select Your Order Preference")
                    .font(.system(size: 12))
                
                // Service Type Cards
                VStack(spacing: 10) {
                    if ((viewmodel.cart.serviceType?.first(where: {$0 == "Pickup"})) != nil) {
                        ServiceTypeCard(
                            title: "Pickup",
                            description: "Pick up your order at the store.",
                            icon: "bag.fill",
                            isSelected: selectedServiceType == "Pickup"
                        ) {
                            selectedServiceType = "Pickup"
                        }
                    }
                    
                    if ((viewmodel.cart.serviceType?.first(where: {$0 == "Pay at Pickup"})) != nil) {
                        ServiceTypeCard(
                            title: "Pay at Pickup",
                            description: "Pay when you pick up your order.",
                            icon: "dollarsign.circle.fill",
                            isSelected: selectedServiceType == "PayAtPickup"
                        ) {
                            selectedServiceType = "PayAtPickup"
                        }
                    }
                    if ((viewmodel.cart.serviceType?.first(where: {$0 == "Delivery"})) != nil) {
                        ServiceTypeCard(
                            title: "Delivery",
                            description: "Get your order delivered to your doorstep.",
                            icon: "shippingbox.fill",
                            isSelected: selectedServiceType == "Delivery"
                        ) {
                            selectedServiceType = "Delivery"
                        }
                    }
                }
            } .padding(.vertical, 10)
            
            CheckoutButton(action: {
                if selectedServiceType?.isEmpty ?? false {
                    
                }
                print("Proceeding to checkout for \(viewmodel.cart.store_name)")
            })
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct ServiceTypeCard: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Icon
                Image(systemName: icon)
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .white : .green)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 10)).bold()
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(description)
                        .font(.system(size: 10))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .gray)
                }
                
                Spacer()
                
                // Selected Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.black : Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

class CartSectionViewModel: ObservableObject {
    var cartPubliser: PassthroughSubject<CartResponse, Never> = .init()
    var cart: TotalCartDataViewModel
    @Published var total_amount: Double
    @Published var tax_amount: Double
    @Published var total_amount_with_tax: Double
    private var cancellables: Set<AnyCancellable> = []
    init(cart: TotalCartDataViewModel) {
        self.cart = cart
        self.total_amount = cart.total_amount
        self.total_amount_with_tax = cart.total_amount_with_tax
        self.tax_amount = cart.tax_amount
        updateCart()
    }
    
    func updateCart() {
        cartPubliser.sink { _ in
            
        } receiveValue: { cart in
            let sectionCart = cart.all_carts.filter({$0.cart_id == self.cart.id}).first
            if let sectionCart {
                self.tax_amount = sectionCart.tax_amount
                self.total_amount_with_tax = sectionCart.total_amount_with_tax
                self.tax_amount = sectionCart.tax_amount
            }
        }.store(in: &cancellables)

    }

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
    let cart: TotalCartDataViewModel
    
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
    let product: GetCartProduct
    @State var showLoginview: Bool = false
    var viewModel: SharedCartModel
    var cart: TotalCartDataViewModel? = nil
    var cartPubliser: PassthroughSubject<CartResponse, Never>?
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
                
                Text("\(product.price?.formattedPrice ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.black)
                CartButtonView(showLoginview: $showLoginview,
                               viewModel: viewModel,
                               cartPubliser: cartPubliser)
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

