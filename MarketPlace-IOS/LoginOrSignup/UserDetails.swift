//
//  UserDetails.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import Foundation

class UserDetails {
    static let shared = UserDetails() // Singleton instance
    
    // Static properties to store user details
    static var userId: String? {
        get {
            return UserDefaults.standard.string(forKey: "userId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
        }
    }
    
    static var userType: String? {
        get {
            return UserDefaults.standard.string(forKey: "userType")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userType")
        }
    }
    
    static var mobileNumber: String? {
        get {
            return UserDefaults.standard.string(forKey: "mobileNumber")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mobileNumber")
        }
    }
    
    static var storeId: String? {
        get {
            return UserDefaults.standard.string(forKey: "storeId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "storeId")
        }
    }
    
    static var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "token")
        }
    }

    private init() {} // Private initializer to prevent external instantiation
    
    // Method to populate user details
    static func setUserDetails(from user: User, token: String) {
        self.userId = user.userId
        self.userType = user.userType
        self.mobileNumber = user.mobileNumber
        self.storeId = user.storeId
        self.token = token
    }
    
    // Clear user details (e.g., on logout)
    static func clearUserDetails() {
        self.userId = nil
        self.userType = nil
        self.mobileNumber = nil
        self.storeId = nil
        self.token = nil
        
        // Remove from UserDefaults
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userType")
        UserDefaults.standard.removeObject(forKey: "mobileNumber")
        UserDefaults.standard.removeObject(forKey: "storeId")
        UserDefaults.standard.removeObject(forKey: "token")
    }
}

