//
//  CreateProduct.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
struct CreateProductRequest: Codable, RequestBody {
    var store_type: String?
    var user_id: String?
    let product_name: String
    let description: String
    let price: Double
    let stock: Int
    let category_id: String
    let imageids: [String]
    let isPublish: Bool
}

struct GetAllProductByStoreRequest: Codable, RequestBody {
    var category_id: String?
    var store_id: String?
    var isPublish: Bool?
    var page: Int = 1
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
    var products: [Product]

    struct Product: Codable {
        let productId: String
        let storeId: String
        let productName: String
        let price: Double
        let stock: Int
        let description: String
        let category_id: String
        let createdAt: String
        let updatedAt: String?
        let imageids: [String]

        enum CodingKeys: String, CodingKey {
            case productId = "product_id"
            case storeId = "store_id"
            case productName = "product_name"
            case price
            case stock
            case description
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case imageids
            case category_id
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

