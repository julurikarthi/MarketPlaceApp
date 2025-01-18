//
//  CreateStore.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine

struct CreateStoreRequest: Codable {
    let storeName: String
    let storeType: String
    let imageId: String
    let userId: String
    let taxPercentage: Double
    let pincode: Int
    let state: String
    let serviceType: [String]

    enum CodingKeys: String, CodingKey {
        case storeName = "store_name"
        case storeType = "store_type"
        case imageId = "image_id"
        case userId = "user_id"
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


class CreateViewModel: ObservableObject {
    
    @Published var storeResponse: CreateStoreResponse?
    @Published var isLoading: Bool = false

    func sendCreateStoreRequest(storeRequest: CreateStoreRequest) {
        guard let url = URL(string: String.createStore()) else { return }

        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: storeRequest,
            responseType: CreateStoreResponse.self
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
                self.storeResponse = response
            }
        )
    }
    
}
