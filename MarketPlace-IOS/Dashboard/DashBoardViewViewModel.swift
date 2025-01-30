//
//  DashBoardViewViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/30/25.
//

import Foundation
import Combine
class DashBoardViewViewModel: ObservableObject {
    @Published var movetoSelectLocation: Bool = false
    @Published var address: Address?
    let locationManager = LocationManager()
    
    @Published var state: String?
    @Published var pincode: String?
    
    func getCurrentLocation() {
        locationManager.requestLocation()
        locationManager.onLocationUpdate = { newState, newPincode in
            self.state = newState
            self.pincode = newPincode
            print(self.state)
        }
    }
}
