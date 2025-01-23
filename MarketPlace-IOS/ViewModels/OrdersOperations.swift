//
//  OrdersOperations.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
struct FetchStoreOrderRequest: Codable, RequestBody {
    var user_id: String?
    
    let store_id: String
    enum CodingKeys: String, CodingKey {
        case store_id = "store_id"
    }
}

struct OrderResponse: Codable {
    let success: Bool
    let orders: [Order]
    let total_orders: Int
    let page: Int
    let total_pages: Int
    
    struct Order: Codable {
        let order_id: String
        let customer_id: String
        let customer_name: String
        let customer_email: String
        let customer_phone: String
        let products: [Product]
        let total_price: Double
        let tax_amount: Double
        let total_price_with_tax: Double
        let status: String
        let payment_type: String
        let created_at: String
        
        struct Product: Codable {
            let product_id: String
            let product_name: String
            let price: Double
            let quantity: Int
        }
    }
}

struct UpdateOrderStatusRequest: Codable, RequestBody {
    var user_id: String?
    
    let status: String
    let order_id: String
}

struct UpdateOrderResponse: Codable {
    let success: Bool
    let message: String
    let order_id: String
    let new_status: String
}

class OrdersOperations: ObservableObject {
    @Published var responce: OrderResponse?
    @Published var updateResponce: UpdateOrderResponse?
    var cancellables = Set<AnyCancellable>()
    /// ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"]
    func fetchAllProductsByStore(request: FetchStoreOrderRequest) {
        let cancellable = NetworkManager.shared.performRequest(
            url: .getOrdersForStore(),
            method: .POST,
            payload: request,
            responseType: OrderResponse.self
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request completed successfully.")
                case .failure(let error):
                    print("Request failed: \(error.localizedDescription)")
                }
            },
            receiveValue: { response in
                self.responce = response
            }
        )
        
    }
    
    
    func updateOrderStatus(request: UpdateOrderStatusRequest) {
        let cancellable = NetworkManager.shared.performRequest(
            url: .getOrdersForStore(),
            method: .POST,
            payload: request,
            responseType: UpdateOrderResponse.self
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request completed successfully.")
                case .failure(let error):
                    print("Request failed: \(error.localizedDescription)")
                }
            },
            receiveValue: { response in
                self.updateResponce = response
            }
        )
    }
    
}
