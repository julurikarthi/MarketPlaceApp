//
//  UserDetails.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/21/25.
//

import Foundation
import AVFoundation
import Photos
import SwiftUICore
import CoreLocation

class UserDetails {
    static let shared = UserDetails()

    var counties: [Country] = []
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
    
    static var store_type: String? {
        get {
            return UserDefaults.standard.string(forKey: "store_type")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "store_type")
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
            UserDefaults.standard.set(Date(), forKey: "tokenCreationTime")
        }
    }
    
    func shouldRenewToken() -> Bool {
        if let tokenCreationTime = UserDefaults.standard.object(forKey: "tokenCreationTime") as? Date {
            let timeElapsed = Date().timeIntervalSince(tokenCreationTime)
            // If 30 hours have passed, renew the token
            return timeElapsed >= 30 * 60 * 60
        }
        return false
    }
    
    func renewToken() {
        
        
    }
    
    static var isLoggedIn: Bool {
        return token != nil
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
    
    static var isAppOwners: Bool {
        guard let target = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return false
        }
        return target != "MarketPlace-IOS-Customers"
    }

}

extension UserDetails {
    
    class func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            print("✅ Camera access already granted")
            UserDetails.requestPhotoLibraryPermission()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    UserDetails.requestPhotoLibraryPermission()
                    print("✅ Camera access granted")
                } else {
                    print("❌ Camera access denied")
                }
            }
            
        case .denied, .restricted:
            print("❌ Camera access denied or restricted")
            
        @unknown default:
            break
        }
    }
    
    class func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            print("✅ Photo library access already granted")
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    print("✅ Photo library access granted")
                } else {
                    print("❌ Photo library access denied")
                }
            }
            
        case .denied, .restricted:
            print("❌ Photo library access denied or restricted")
            
        @unknown default:
            break
        }
    }
    
    class func requestLocationPermission(completion: ((CLAuthorizationStatus) -> Void)? = nil) {
        let locationManager = LocationManager()
        locationManager.requestLocationPermission()
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
                counties.append(countryValue)
            }
        } catch {
            print("Error decoding countries.json: \(error)")
            return
        }
    }
}



class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    var onPermissionChange: ((CLAuthorizationStatus) -> Void)? // Callback for permission changes
    var onLocationUpdate: ((String?, String?, String?) -> Void)? // Callback for state, pincode, and country
    var onError: ((Error) -> Void)? // Callback for errors
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Request Location Permission
    func requestLocationPermission() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location access already granted")
            onPermissionChange?(status)
            
        case .notDetermined:
            print("⚠️ Requesting location permission")
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            print("❌ Location access denied or restricted")
            onPermissionChange?(status)
            
        @unknown default:
            print("⚠️ Unknown authorization status")
            break
        }
    }
    
    // MARK: - Request Current Location
    func requestLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 Starting location updates")
            locationManager.startUpdatingLocation()
            
        case .notDetermined:
            print("⚠️ Location permission not determined, requesting permission")
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            print("❌ Location access denied or restricted")
            
        @unknown default:
            print("⚠️ Unknown authorization status")
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Location access granted")
            onPermissionChange?(status)
            
        case .denied, .restricted:
            print("❌ Location access denied or restricted")
            onPermissionChange?(status)
            
        case .notDetermined:
            print("⚠️ Location permission not determined yet")
            
        @unknown default:
            print("⚠️ Unknown authorization status")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Fetch address using reverse geocoding
        fetchAddress(from: location)
        
        // Stop updating location to save battery
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Failed to get location: \(error.localizedDescription)")
        
        // Trigger the error callback if provided
        onError?(error)
    }
    
    // MARK: - Reverse Geocoding to Fetch Address
    private func fetchAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("❌ Failed to reverse geocode location: \(error.localizedDescription)")
                self?.onError?(error)
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("❌ No placemarks found")
                return
            }
            
            let state = placemark.administrativeArea // State
            let postalCode = placemark.postalCode // Pincode
            let country = placemark.isoCountryCode // Country
            
            print("📍 State: \(state ?? "N/A"), Postal Code: \(postalCode ?? "N/A"), Country: \(country ?? "N/A")")
            
            // Trigger the callback with fetched address details
            self?.onLocationUpdate?(state, postalCode, country)
        }
    }
}
