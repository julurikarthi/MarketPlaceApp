//
//  OrdersOperations.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
struct FetchStoreOrderRequest: Codable, RequestBody {
    let customer_id: String
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
    @Published var updateResponce: UpdateOrderResponse?
    @Published var ordersdata: [Order]?
    var cancellables = Set<AnyCancellable>()
    /// ["Pending", "Processing", "Shipped", "Delivered", "Cancelled"]
    func fetchAllProductsByStore(request: FetchStoreOrderRequest) {
        let cancellable = NetworkManager.shared.performRequest(
            url: .getOrdersForStore(),
            method: .POST,
            payload: request,
            responseType: Order.self
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
                
            }
        )
        
    }
    
    func fetchAllProductsByCustomer() {
        if UserDetails.userId == nil {
            return
        }
        let request = FetchStoreOrderRequest(customer_id: UserDetails.userId ?? "")
        NetworkManager.shared.performRequest(
            url: .getOrdersForCustomer(),
            method: .POST,
            payload: request,
            responseType: OrdersReposnce.self
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
                self.ordersdata = response.orders
            }
        ).store(in: &cancellables)
        
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

struct OrdersReposnce: Codable {
    let orders: [Order]
}

struct Order: Identifiable, Codable {
    let id: String
    let storeId: String
    let storeName: String
    let storeAddress: String
    let storeImage: String?
    let products: [OrderProduct]
    let totalPrice: Double
    let taxAmount: Double
    let totalPriceWithTax: Double
    let status: String
    let paymentType: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id = "order_id"
        case storeId = "store_id"
        case storeName = "store_name"
        case storeAddress = "store_address"
        case storeImage = "store_image"
        case products
        case totalPrice = "total_price"
        case taxAmount = "tax_amount"
        case totalPriceWithTax = "total_price_with_tax"
        case status
        case paymentType = "payment_type"
        case createdAt = "created_at"
    }
}

struct OrderProduct: Identifiable, Codable {
    let id: String
    let productName: String
    let quantity: Int
    let price: Double
    let imageIds: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "product_id"
        case productName = "product_name"
        case quantity
        case price
        case imageIds = "imageids"
    }
}
