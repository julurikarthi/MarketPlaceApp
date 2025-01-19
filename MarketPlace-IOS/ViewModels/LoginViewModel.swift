//
//  LoginRequest.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation
import Combine

public extension String {
    static let GET = "get"
    static let POST = "post"
}

struct User: Codable {
    let user_id: String
    let name: String
    let email: String
    let userType: String
    let mobileNumber: String
    let store_id: String
}

struct LoginResponse: Codable {
    let message: String
    let token: String
    let user: User
}
struct LoginRequest: Codable {
    let email: String
    let password: String
    let userType: String
}



class LoginViewModel: ObservableObject {
    @Published var loginResponse: LoginResponse?
    @Published var isLoading: Bool = false
    func loginUser(loginRequest: LoginRequest) {
        let cancellable = NetworkManager.shared.performRequest(
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
                self.loginResponse = response
            }
        )
    }
    
}
