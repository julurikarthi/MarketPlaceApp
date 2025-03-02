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
                    
                    if let product = products.first {
                        let quantity = self?.getQuantity(for: product.productID, variantType: product.variant_type, from: response) ?? 0
                        
                        self?.updateCart(id: product.id,
                                         productID: product.productID,
                                         quantity: quantity,
                                         variant_type: product.variant_type)
                        
                        completionHandler(self?.cartItemCount, quantity, response)
                    }
                }

            }
        )
        .store(in: &cancellables)
       
    }
    
    func updateCart(id: String, productID: String, quantity: Int, variant_type: String?) {
        if let index = updatedCartdata.firstIndex(where: { $0.id == id }) {
            updatedCartdata[index].quantity = quantity
        } else {
            updatedCartdata.append(UpdatedCart(productID: productID, quantity: quantity, variant_type: variant_type)) // Add new entry
        }
    }
    
    func getQuantity(for productID: String, variantType: String?, from response: CartResponse) -> Int {
        return response.all_carts.reduce(0) { total, cart in
            total + cart.products
                .filter { $0.product_id == productID && $0.variant_type == variantType }
                .reduce(0) { $0 + $1.quantity }
        }
    }
    
    func refreshCartQuantity() {
        
    }


}

struct UpdatedCart {
    var id: String { productID + (variant_type ?? "") }
    let productID: String
    var quantity: Int
    var variant_type: String?
}

struct CreateCartRequest: Codable, RequestBody {
    let products: [CartProduct]
    let customer_id: String
}

struct CartProduct: Codable, Identifiable {
    var id: String { productID + (variant_type ?? "") }
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
    let variant_type: String?
    let products: [CartProductResponse]
    let total_amount: Double
    let tax_amount: Double
    let total_amount_with_tax: Double
}

// MARK: - Product
struct CartProductResponse: Codable {
    var id: String { product_id + (variant_type?.removingSpaces ?? "") }
    let product_id: String
    let quantity: Int
    let price: Double
    let variant_type: String?
    let product_name: String
}
