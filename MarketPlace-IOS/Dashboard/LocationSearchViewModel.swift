//
//  LocationSearchViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//

import Foundation

class LocationSearchViewModel: ObservableObject {
    let locationManager = LocationManager()
    @Published var state: String?
    @Published var pincode: String?
    
    func getCurrentLocation(completionHander: @escaping()-> Void) {
        locationManager.requestLocation()
        locationManager.onLocationUpdate = { newState, newPincode in
            self.state = newState
            self.pincode = newPincode
            completionHander()
        }
    }
}
