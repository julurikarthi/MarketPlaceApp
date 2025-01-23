//
//  CreateProduct.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
struct CreateProductRequest: Codable, RequestBody {
    var user_id: String?
    
    let productName: String
    let description: String
    let price: Double
    let stock: Int
    let categoryId: String
    let storeId: String
    let taxPercentage: Double

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case description
        case price
        case stock
        case categoryId = "category_id"
        case storeId = "store_id"
        case taxPercentage = "tax_percentage"
    }
}

struct GetAllProductByStoreRequest: Codable, RequestBody {
    var user_id: String?
    
    let store_id: String
    enum CodingKeys: String, CodingKey {
        case store_id = "store_id"
    }
}

struct CreateProductResponse: Codable {
    let message: String
    let productId: String
    let storeId: String
    let categoryId: String
    let categoryName: String

    enum CodingKeys: String, CodingKey {
        case message
        case productId = "product_id"
        case storeId = "store_id"
        case categoryId = "category_id"
        case categoryName = "category_name"
    }
}

struct GetAllStoreProductsResponse: Codable {
    let products: [Product]

    struct Product: Codable {
        let productId: String
        let storeId: String
        let productName: String
        let price: Double
        let stock: Int
        let description: String
        let createdAt: String
        let updatedAt: String?

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
            case storeId = "store_id"
            case productName = "product_name"
            case price
            case stock
            case description
            case createdAt = "created_at"
            case updatedAt = "updated_at"
        }
    }
}


struct DeleteProductRequest: Codable, RequestBody {
    var user_id: String?
    
    let productId: String

    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
    }
}

struct DeleteOfferRequest: Codable, RequestBody {
    var user_id: String?
    
    let offer_id: String

    enum CodingKeys: String, CodingKey {
        case offer_id = "offer_id"
    }
}

struct SuccessResponse: Codable {
    let message: String
    
}


class CreateProductViewModel: ObservableObject {
    @Published var createProductResponse: CreateProductResponse?
    @Published var isLoading: Bool = false
    @Published var allStoreProducts: GetAllStoreProductsResponse?
    @Published var successResponse: SuccessResponse?
    func sendCreateProductRequest(request: CreateProductRequest, isUpdateProduct: Bool) {
        guard let url = URL(string: isUpdateProduct ? .updateProduct() : .createProduct()) else { return }

        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: CreateProductResponse.self
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
                self.createProductResponse = response
            }
        )
    }
    
    func getAllProductbyStore(request: GetAllProductByStoreRequest) {
        guard let url = URL(string: .getAllProductbyStore()) else { return }

        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: GetAllStoreProductsResponse.self
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
                self.allStoreProducts = response
            }
        )
    }
    
    func deleteProduct(request: DeleteProductRequest) {
        guard let url = URL(string: .deleteProduct()) else { return }

        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: SuccessResponse.self
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
                self.successResponse = response
            }
        )
    }
    
    
    
}
