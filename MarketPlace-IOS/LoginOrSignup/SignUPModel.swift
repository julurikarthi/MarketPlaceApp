//
//  LoginViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/20/25.
//

import SwiftUI

class SignUPModel: ObservableObject {
    
    @Published  var firstName: String = ""
    @Published  var lastName: String = ""
    @Published  var email: String = ""
    @Published  var city: String = ""
    @Published  var pincode: String = ""
    @Published  var address: String = ""
    @Published  var county: String = ""
    @Published  var mobile: String = ""
    @Published  var selectStateText: String = ""
    
    @Published  var firstNameError: Bool = false
    @Published  var lastNameError: Bool = false
    @Published  var emailError: Bool = false
    @Published  var cityError: Bool = false
    @Published  var pincodeError: Bool = false
    @Published  var addressError: Bool = false
    @Published  var countyError: Bool = false
    @Published  var selectStoreTextError: Bool = false
    @Published  var selectStateTextError: Bool = false
    @Published  var mobileError: Bool = false
}
