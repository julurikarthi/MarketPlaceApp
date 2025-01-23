//
//  CreateStore.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine

protocol RequestBody: Encodable {
    var user_id: String? {set get}
}

struct CreateStoreRequest: Codable, RequestBody {
    var user_id: String?
    let storeName: String
    let storeType: String
    let imageId: String
    let taxPercentage: Double
    let pincode: Int
    let state: String
    let serviceType: [String]

    enum CodingKeys: String, CodingKey {
        case storeName = "store_name"
        case storeType = "store_type"
        case imageId = "image_id"
        case user_id = "user_id"
        case taxPercentage = "tax_percentage"
        case pincode
        case state
        case serviceType = "serviceType"
    }
}

struct CreateStoreResponse: Codable {
    let message: String
    let storeId: String

    enum CodingKeys: String, CodingKey {
        case message
        case storeId = "store_id"
    }
}

