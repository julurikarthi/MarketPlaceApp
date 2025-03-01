//
//  CartViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/9/25.
//
import SwiftUI
import Combine
class CartViewModel: ObservableObject {
    @Published var cartItemCount: Int = 0
    var updatedCartdata = [UpdatedCart]()
    private var cancellables = Set<AnyCancellable>()
    
    func createCart(storeID: String, products: [CartProduct], completionHandler: @escaping (_ allCartscount: Int?, _ itemCount: Int?,
                                                                                            _ response: CartResponse?) -> Void) {
        UserDetails.storeId = storeID
        let createCartRequest = CreateCartRequest(
            products: products,
            customer_id: UserDetails.userId ?? ""
        )
        
        NetworkManager.shared.performRequest(
            url: String.createCart(),
            method: .POST,
            payload: createCartRequest,
            responseType: CartResponse.self
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    debugPrint("Cart creation failed:", error)
                    completionHandler(nil, nil, nil)
                }
            },
            receiveValue: { [weak self] response in
                if response.all_carts.count > 0 {
                    let totalCartItems = response.all_carts.reduce(0) { $0 + $1.products.count }
                    self?.cartItemCount = totalCartItems
                    if let productsFirstID = products.first?.productID {
                        let quntity = self?.getQuantity(for: productsFirstID, from: response)
                        self?.updateCart(productID: productsFirstID, quantity: quntity ?? 0)
                        if let product = self?.updatedCartdata.first(where: {$0.productID == productsFirstID}) {
                            completionHandler(self?.cartItemCount, quntity, response)
                        } else {
                            completionHandler(self?.cartItemCount, quntity, response)
                        }
                    }
                }
            }
        )
        .store(in: &cancellables)
       
    }
    
    func updateCart(productID: String, quantity: Int) {
        if let index = updatedCartdata.firstIndex(where: { $0.productID == productID }) {
            updatedCartdata[index].quantity = quantity
        } else {
            updatedCartdata.append(UpdatedCart(productID: productID, quantity: quantity)) // Add new entry
        }
    }
    
    func getQuantity(for productId: String, from response: CartResponse) -> Int {
        return response.all_carts.reduce(0) { total, cart in
            total + cart.products.filter { $0.product_id == productId }.reduce(0) { $0 + $1.quantity }
        }
    }
    
    func refreshCartQuantity() {
        
    }


}

struct UpdatedCart {
    let productID: String
    var quantity: Int
}

struct CreateCartRequest: Codable, RequestBody {
    let products: [CartProduct]
    let customer_id: String
}

struct CartProduct: Codable {
    let productID: String
    let quantity: Int
    let variant_type: String?

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case quantity
        case variant_type
    }
}



// MARK: - CartResponse
struct CartResponse: Codable {
    let message: String
    let total_amount: Double
    let tax_amount: Double
    let total_amount_with_tax: Double
    let all_carts: [Cart]
}

// MARK: - Cart
struct Cart: Codable {
    let cart_id: String
    let store_id: String
    let products: [CartProductResponse]
    let total_amount: Double
    let tax_amount: Double
    let total_amount_with_tax: Double
}

// MARK: - Product
struct CartProductResponse: Codable {
    let product_id: String
    let quantity: Int
    let price: Double
    let product_name: String
}
