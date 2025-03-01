//
//  CreateProduct.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
struct CreateProductRequest: Codable, RequestBody {
    var product_id: String?
    var store_type: String?
    var user_id: String?
    let product_name: String
    let description: String
    let price: Double?
    let stock: Int
    let category_id: String
    let imageids: [String]
    let isPublish: Bool
    var variants: [Variant]?
    var search_tag: [String]?
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
}

struct Product: Codable, Identifiable {
    var id: String { product_id }
    var product_id: String
    let store_id: String?
    let product_name: String
    let price: Double?
    let stock: Int?
    var description: String?
    let category_id: String?
    let updatedAt: String?
    let imageids: [String]?
    let isAddToCart: Bool?
    var quantity: Int?
    var variants:[ProductVariant]?
    var search_tags: [String]?
}

struct ProductVariant: Codable {
    var variant_type: String?
    var price: Double?
    var stock: Int?
}

struct ProductDashBoard: Codable, Identifiable {
    var id: String { _id } 
    let _id: String
    let product_name: String
    let description: String
    let price: Double?
    let stock: Int?
    let store_id: String
    let category_id: String
    let imageids: [String]
    let isPublish: Bool
    let isAddToCart: Bool
    let quantity: Int
    let store_type: String
    let variants: [ProductVariant]?
}

struct DeleteProductRequest: Codable, RequestBody {
    var user_id: String?
    
    let product_id: String

    enum CodingKeys: String, CodingKey {
        case product_id = "product_id"
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

