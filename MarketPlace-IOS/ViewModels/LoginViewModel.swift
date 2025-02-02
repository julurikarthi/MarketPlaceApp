//
//  LoginRequest.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine
import SwiftUI

public extension String {
    static let GET = "get"
    static let POST = "post"
    static let storeOwner = "storeOwner"
    static let customer = "customer"
}

struct LoginResponse: Codable {
    let message: String
    let token: String
    let user: User
}

struct User: Codable {
    let userId: String
    let userType: String
    let mobileNumber: String
    let storeId: String?
    let store_type: String?

    // CodingKeys to map JSON keys to Swift property names if needed
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userType
        case mobileNumber
        case storeId = "store_id"
        case store_type
    }
}

struct LoginRequest: Codable, RequestBody {
    var user_id: String?
    
    let mobileNumber: String
    let userType: String
}



class LoginViewModel: ObservableObject {
    @Published  var mobile: String = ""
    @Published  var mobileError: Bool = false
    @Published var loginResponse: LoginResponse?
    @Published var isLoading: Bool = false
    @Published var country: Country?
    @MainThreadPublished var showProgressIndicator: Bool = false
    @AppStorage("userToken") var userToken: String?
    let locationManager = LocationManager()

    private var cancellables = Set<AnyCancellable>()
    @Published var movetoDashboard: Bool = false
    @Published var movetoStore: Bool = false
    @Published var movetoHome: Bool = false
    @Published var createStore: Bool = false
    func loginUser(loginRequest: LoginRequest) {
        showProgressIndicator = true
        NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: loginRequest,
            responseType: LoginResponse.self
        )
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Request completed successfully.")
                case .failure(let error):
                    print("Request failed: \(error.localizedDescription)")
                    self.showProgressIndicator = false
                }
            },
            receiveValue: { response in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.loginResponse = response
                    self.userToken = response.token
                    UserDetails.mobileNumber = response.user.mobileNumber
                    UserDetails.token = response.token
                    UserDetails.userId = response.user.userId
                    UserDetails.userType = response.user.userType
                    UserDetails.storeId = response.user.storeId
                    UserDetails.mobileNumber = response.user.mobileNumber
                    UserDetails.store_type = response.user.store_type
                    DispatchQueue.main.async { [self] in
                        self.showProgressIndicator = false
                        if response.user.userType == "storeOwner" {
                            if response.user.storeId == nil {
                                self.movetoStore = true
                            } else {
                                self.movetoHome = true
                            }
                        } else if response.user.userType == "customer" {
                            self.movetoDashboard = true
                        }
                    }
                    
                }
            }
            
        ).store(in: &cancellables)
        
    }
    
    func fetchLocation() {
        locationManager.requestLocation()
        
        locationManager.onLocationUpdate = { newState, newPincode, countryCode in
           let country =  UserDetails.shared.counties.filter({$0.code == countryCode}).first
            self.country = country
        }
    }
   
    
    func isValidMobileNumber(_ number: String) -> Bool {
        // Remove non-numeric characters (like spaces, parentheses, or dashes)
        let cleanedNumber = number.filter { $0.isNumber }
        
        // Check if the cleaned number has exactly 10 digits
        let regex = "^[0-9]{10}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: cleanedNumber)
    }
    
    func continueAction() {
        if isValidMobileNumber(mobile)  {
            let digitsOnly = mobile.filter { $0.isNumber }
            let numberformat = (country?.dialCode ?? .empty) + digitsOnly
            let request = LoginRequest(mobileNumber: numberformat, userType: .storeOwner)
            loginUser(loginRequest: request)
        } else {
            mobileError = true
        }
    }

    
}


@propertyWrapper
class MainThreadPublished<T>: ObservableObject {
    @Published private var value: T
    private var cancellables = Set<AnyCancellable>()
    
    // Publisher to expose the wrapped value
    var projectedValue: Published<T>.Publisher {
        return $value
    }

    var wrappedValue: T {
        get { value }
        set {
            // Check if we're already on the main thread
            if Thread.isMainThread {
                self.value = newValue
            } else {
                DispatchQueue.main.async {
                    self.value = newValue
                }
            }
        }
    }


    init(wrappedValue: T) {
        self.value = wrappedValue
    }
}
