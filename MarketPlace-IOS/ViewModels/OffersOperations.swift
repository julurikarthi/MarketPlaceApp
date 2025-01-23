//
//  OffersOperations.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//


import Foundation

struct CreateOfferRequest: Codable, RequestBody {
    var user_id: String?
    
    let storeId: String
    let imageId: String
    let offerDescription: [String]

    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case imageId = "image_id"
        case offerDescription = "offerDescription"
    }
}

struct CreateOfferResponse: Codable {
    let message: String
    let offerId: String
    let storeId: String
    let offerDescription: [String]
    let imageId: String

    enum CodingKeys: String, CodingKey {
        case message
        case offerId = "offer_id"
        case storeId = "store_id"
        case offerDescription = "offerDescription"
        case imageId = "image_id"
    }
}

struct GetAllStrorequest: Codable, RequestBody {
    var user_id: String?
    
    let storeId: String
   
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        
    }
}

struct OfferResponse: Codable {
    let offers: [Offer]
    
    struct Offer: Codable {
        let offer_id: String
        let store_id: String
        let offerDescription: [String]
        let image_id: String
        let created_at: String
        let updated_at: String
    }
}

class OffersOperations: ObservableObject {
    @Published var successResponse: SuccessResponse?
    @Published var createOfferResponse: CreateOfferResponse?
    @Published var getAllStoresOffersResponse: OfferResponse?
    
    func deleteOffer(request: DeleteOfferRequest) {

        let cancellable = NetworkManager.shared.performRequest(
            url: .deleteOffer(),
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
    
    func createOffer(request: CreateOfferRequest) {

        let cancellable = NetworkManager.shared.performRequest(
            url: .createOffer(),
            method: .POST,
            payload: request,
            responseType: CreateOfferResponse.self
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
                self.createOfferResponse = response
            }
        )
    }
    
    func getallStoreOffers(request: GetAllStrorequest) {
        let cancellable = NetworkManager.shared.performRequest(
            url: .getAllProductbyStore(),
            method: .POST,
            payload: request,
            responseType: OfferResponse.self
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
                self.getAllStoresOffersResponse = response
            }
        )
    }
    
}
