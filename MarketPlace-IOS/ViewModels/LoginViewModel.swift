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
    
    // CodingKeys to map JSON keys to Swift property names if needed
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case userType
        case mobileNumber
        case storeId = "store_id"
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
    @Published var showProgressIndicator: Bool = true
    @AppStorage("userToken") var userToken: String?
    
    private var cancellables = Set<AnyCancellable>()
    @Published var movetoDashboard: Bool = false
    func loginUser(loginRequest: LoginRequest) {
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
                }
            },
            receiveValue: { response in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.loginResponse = response
                    self.userToken = response.token
                    UserDetails.mobileNumber = response.user.mobileNumber
                    UserDetails.token = response.token
                    UserDetails.userType = response.user.userType
                    movetoDashboard = true
                }
            }
            
        ).store(in: &cancellables)
        
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
            let request = LoginRequest(mobileNumber: mobile, userType: .storeOwner)
            loginUser(loginRequest: request)
        } else {
            mobileError = true
        }
    }

    
}
