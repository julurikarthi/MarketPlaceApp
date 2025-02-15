//
//  TotalCartViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 2/14/25.
//
import SwiftUI
import Combine

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
    var serviceType: [String]?
}

class TotalCartDataViewModel: ObservableObject, Identifiable {
    let id: String
    let store_id: String
    let store_name: String
    let store_image: String
    @Published var products: [Product]
    @Published var total_amount: Double
    @Published var tax_amount: Double
    @Published var total_amount_with_tax: Double
    var serviceType: [String]?

    init(cart: CartModel) {
        self.id = cart.cart_id
        self.store_id = cart.store_id
        self.store_name = cart.store_name
        self.store_image = cart.store_image
        self.products = cart.products
        self.total_amount = cart.total_amount
        self.tax_amount = cart.tax_amount
        self.total_amount_with_tax = cart.total_amount_with_tax
        self.serviceType = cart.serviceType
    }
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
    @Published var carts: [TotalCartDataViewModel] = []
    @Published var error: String? = nil
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
                    self?.error = response.error
                    self?.carts = response.carts?.map { TotalCartDataViewModel(cart: $0) } ?? []
                }
            }
        )
        .store(in: &cancellables)
     
    }
    
}

struct TotalCartRequest: RequestBody {
    let customer_id: String
}

struct TotalCartsResponce: Codable {
    let carts: [CartModel]?
    let error: String?
}


