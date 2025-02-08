//
//  DashBoardViewViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//

import Foundation
import Combine
class DashBoardViewViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var movetoSelectLocation: Bool = false
    @Published var address: Address?
    let locationManager = LocationManager()
    var imageIds: [String]?

    @Published var state: String?
    @Published var pincode: String?
    private var cancellables = Set<AnyCancellable>()
    @Published var storesResponce: StoresResponse?
    
    func getCurrentLocation() async {
        await withCheckedContinuation { continuation in
            locationManager.requestLocation()
            locationManager.onLocationUpdate = { newState, newPincode, country in
                self.state = newState
                self.pincode = newPincode
                continuation.resume() // Resume the async task once the location is updated
            }
        }
    }

    
    func getDashboardData() {
        isLoading = false
        let request = DashboardDataRequest(pincode: "28078", state: "NC")
        NetworkManager.shared.performRequest(url: String.getDashboardData(), method: .POST, payload: request, responseType: StoresResponse.self).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request completed successfully.")
                case .failure(let error):
                    print("Request failed: \(error.localizedDescription)")
                }
            },
            receiveValue: { response in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.storesResponce = response
                }
            }
        ).store(in: &cancellables)
    }
    

   
}

struct DashboardDataRequest: Codable, RequestBody {
    let pincode: String?
    let state: String?
}

struct StoresResponse: Codable {
    let stores: [StoreData]
    let page: Int
    let totalStores: Int
    
    enum CodingKeys: String, CodingKey {
        case stores
        case page
        case totalStores = "total_stores"
    }
}

// Store Model
struct StoreData: Codable, Identifiable {
    let id = UUID()
    let storeId: String?
    let storeName: String?
    let storeType: String?
    let pincode: Int?
    let state: String?
    let imageId: String?
    let customerId: String?
    let taxPercentage: Double?
    let serviceType: [String]?
    let address: String?
    let street: String?
    let city: String?
    let products: [ProductDashBoard]
    
    enum CodingKeys: String, CodingKey {
        case storeId = "store_id"
        case storeName = "store_name"
        case storeType = "store_type"
        case pincode
        case state
        case imageId = "image_id"
        case customerId = "customer_id"
        case taxPercentage = "tax_percentage"
        case serviceType = "service_type"
        case address
        case street
        case city
        case products
    }
}

class StoreCardViewModel: ObservableObject {
    @Published var store: StoreData
    init(store: StoreData) {
        self.store = store
    }
}
