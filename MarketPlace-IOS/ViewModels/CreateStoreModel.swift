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
    var store_id: String? {set get}
    var userType: String? {set get}
}

extension RequestBody {
    var store_id: String? {
        get { UserDetails.storeId }
        set { }
    }
    
    var user_id: String? {
        get { UserDetails.userId }
        set { }
    }
    var userType: String? {
        get { UserDetails.userType }
        set { }
    }
}
private enum CodingKeys: CodingKey {
    case user_id
    case store_id
}


extension RequestBody {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)

        // Encode user_id and store_id explicitly if available
        if let userId = user_id {
            try container.encode(userId, forKey: DynamicCodingKeys(stringValue: "user_id")!)
        }
        if let storeId = store_id {
            try container.encode(storeId, forKey: DynamicCodingKeys(stringValue: "store_id")!)
        }
        if let userType = userType {
            try container.encode(userType, forKey: DynamicCodingKeys(stringValue: "userType")!)
        }
        
        // Encode all other properties dynamically using reflection
        let mirror = Mirror(reflecting: self)

        for child in mirror.children {
            guard let key = child.label else { continue }

            // Skip encoding 'user_id' and 'store_id' since we already handled them
            if key == "user_id" || key == "store_id" || key == "userType"{
                continue
            }

            if let value = child.value as? Encodable {
                let codingKey = DynamicCodingKeys(stringValue: key)!
                try container.encode(value, forKey: codingKey)
            }
        }
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

struct CreateStoreRequest: Codable, RequestBody {
    let store_name: String
    let store_type: String
    let image_id: String
    let tax_percentage: Double
    let pincode: Int
    let state: String
    let city: String
    let street: String
    let serviceType: [String]
    let currencycode: String

    enum CodingKeys: String, CodingKey {
        case store_name = "store_name"
        case store_type = "store_type"
        case image_id = "image_id"
        case tax_percentage = "tax_percentage"
        case pincode
        case state
        case city
        case street
        case currencycode
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

