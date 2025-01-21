//
//  UserDetails.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import Foundation

class UserDetails {
    static let shared = UserDetails() // Singleton instance
    
    // Properties to store user details
    var userId: String?
    var userType: String?
    var mobileNumber: String?
    var storeId: String?
    var token: String?
    
    private init() {} // Private initializer to prevent external instantiation
    
    // Method to populate user details
    func setUserDetails(from user: User, token: String) {
        self.userId = user.userId
        self.userType = user.userType
        self.mobileNumber = user.mobileNumber
        self.storeId = user.storeId
        self.token = token
    }
    
    // Clear user details (e.g., on logout)
    func clearUserDetails() {
        self.userId = nil
        self.userType = nil
        self.mobileNumber = nil
        self.storeId = nil
        self.token = nil
    }
}
