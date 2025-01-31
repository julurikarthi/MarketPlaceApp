//
//  LoginViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/20/25.
//

import SwiftUI
import Combine

class CreateStoreViewModel: ObservableObject {
    
    @Published  var email: String = ""
    @Published  var storeName: String = ""
    @Published  var city: String = ""
    @Published  var pincode: String = ""
    @Published  var taxPercentageRequired: String = ""
    @Published  var address: String = ""
    
    @Published  var selectStateText: String = "NC"
    @Published  var selectedStoreType: String = "Select Store type"

    @Published  var imageUploadError: Bool = false
    @Published  var selectedImage: [UIImage] = []
    

    @Published  var emailError: Bool = false
    @Published  var storeNameError: Bool = false
    @Published  var cityError: Bool = false
    @Published  var pincodeError: Bool = false
    @Published  var addressError: Bool = false
    @Published  var countyError: Bool = false
    
    @Published  var selectStoreTypeError: Bool = false
    @Published  var selectStatError: Bool = false
    @Published  var taxPercentageRequiredError: Bool = false
    
    @Published var storeResponse: CreateStoreResponse?
    var getStoreDetailsResponce: StoreServiceData?
    @Published var storeCreateRequest: CreateStoreRequest?
    @Published var isLoading: Bool = false
    @Published var isPickup = false
    @Published var isPayAtPickup = false
    @Published var isDelivery = false
    @Published var selectServiceTypeError = false
    @Published var showProgressIndicator = false
    @Published var storeTypes = ["Select Store type"]
    @Published var serviceTypes = [String]()
    @Published var image_id: [String] = []
    var counties: [String] = ["NC"]
    var storeDetails: StoreServiceData?
    private var cancellables = Set<AnyCancellable>()
    init() {
        loadCountries()
    }
    func createStore() {
        if validateInputs() {
            let request = CreateStoreRequest(storeName: storeName,
                                             storeType: selectedStoreType,
                                             imageId: image_id.first ?? "",
                                             taxPercentage: taxPercentageRequired.doubleValue,
                                             pincode: pincode.intValue,
                                             state: selectStateText,
                                             serviceType: serviceTypes)
            sendCreateStoreRequest(storeRequest: request)
        }
    }
    func validateInputs() -> Bool {
        imageUploadError = true ? selectedImage == nil : false
        storeNameError = storeName.isEmpty
        cityError = city.isEmpty
        pincodeError = pincode.isEmpty || !isValidPincode(pincode)
        addressError = address.isEmpty
        countyError = selectStateText.isEmpty
        taxPercentageRequiredError = taxPercentageRequired.isEmpty
        // Check for each condition and return false if any error occurs
        let imageUploadValid = selectedImage != nil
        let storeNameValid = !storeName.isEmpty
        let cityValid = !city.isEmpty
        let pincodeValid = !pincode.isEmpty && isValidPincode(pincode)
        let addressValid = !address.isEmpty
        let countyValid = !selectStateText.isEmpty
        let taxPercentageValid = !taxPercentageRequired.isEmpty
        if selectedStoreType == "Select Store type" {
            selectStoreTypeError = true
        } else {
            selectStoreTypeError = false
        }
        if isPickup || isPayAtPickup || isDelivery {
            selectServiceTypeError = false
        } else {
            selectServiceTypeError = true
        }
        if isPickup {
            if !serviceTypes.contains("Pickup") {
                serviceTypes.append("Pickup")
            }
        }
        if isPayAtPickup {
            if !serviceTypes.contains("Pickup at Pay") {
                serviceTypes.append("Pickup at Pay")
            }
        }
        if isPayAtPickup {
            if !serviceTypes.contains("Delivery") {
                serviceTypes.append("Delivery")
            }
        }
        return imageUploadValid && storeNameValid && cityValid &&
        pincodeValid && addressValid && countyValid && taxPercentageValid
        && !selectStoreTypeError && !selectServiceTypeError
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPincode(_ pincode: String) -> Bool {
        return pincode.count >= 5 // Replace 5 with your required minimum length
    }
    
    func loadCountries() {
        guard let url = Bundle.main.url(forResource: "countries", withExtension: "json") else {
            print("Could not find counties.json in the bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let countries = try decoder.decode([Country].self, from: data)
            countries.forEach { countryValue in
                counties.append(countryValue.code)
            }
        } catch {
            print("Error decoding countries.json: \(error)")
            return 
        }
    }

    func sendCreateStoreRequest(storeRequest: CreateStoreRequest) {
        guard URL(string: String.createStore()) != nil else { return }
        showProgressIndicator = true
         NetworkManager.shared.performRequest(
            url: .createStore(),
            method: .POST,
            payload: storeRequest,
            responseType: CreateStoreResponse.self
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    DispatchQueue.main.async {
                        self.showProgressIndicator = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        let errorDescription = error as NSError
                        let error = errorDescription.userInfo["error"] as? String
                        self.showProgressIndicator = false
                        print("Request failed: \(String(describing: error))")
                    }
                    
                }
            },
            receiveValue: { response in
                self.storeResponse = response
                DispatchQueue.main.async {
                    self.showProgressIndicator = false
                }
            }
        ).store(in: &cancellables)
    }
    
    func getStoreDetailsData() {
        showProgressIndicator = true
        guard URL(string: String.getStoreDetails()) != nil else { return }
        
        _ = NetworkManager.shared.performRequest(url: .getStoreDetails(),
                                                 method: .POST,
                                                 payload: EmptyRequestBody(),
                                                 responseType: StoreServiceData.self)
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
                self.getStoreDetailsResponce = response
                DispatchQueue.main.async {
                    response.storeTypes.forEach { storeType in
                        self.storeTypes.append(storeType)
                    }
                    self.showProgressIndicator = false
                }
            }
        ).store(in: &cancellables)
        
    }

}



struct Country: Codable {
    let name: String
    let dialCode: String
    let emoji: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case dialCode = "dial_code"
        case emoji
        case code
    }
}

struct StoreServiceData: Codable {
    let storeTypes: [String]
    let serviceTypes: [String]
}
struct EmptyRequestBody: RequestBody {
    var user_id: String?
}
extension String {
    /// Convert a String to an Int value, returns 0 if conversion fails
    var intValue: Int {
        return Int(self) ?? 0
    }

    /// Convert a String to a Double value, returns 0.0 if conversion fails
    var doubleValue: Double {
        return Double(self) ?? 0.0
    }

    /// Convert a String to a Float value, returns 0.0 if conversion fails
    var floatValue: Float {
        return Float(self) ?? 0.0
    }
}
