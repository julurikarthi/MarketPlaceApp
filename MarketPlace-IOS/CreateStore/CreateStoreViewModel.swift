//
//  LoginViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/20/25.
//

import SwiftUI

class CreateStoreViewModel: ObservableObject {
    
    @Published  var email: String = ""
    @Published  var storeName: String = ""
    @Published  var city: String = ""
    @Published  var pincode: String = ""
    @Published  var taxPercentageRequired: String = ""
    @Published  var address: String = ""
    @Published  var county: String = ""
    
    @Published  var selectStateText: String = "NC"
    
    @Published  var imageUploadError: Bool = false
    @Published  var selectedImage: UIImage?
    

    @Published  var emailError: Bool = false
    @Published  var storeNameError: Bool = false
    @Published  var cityError: Bool = false
    @Published  var pincodeError: Bool = false
    @Published  var addressError: Bool = false
    @Published  var countyError: Bool = false
    
    @Published  var selectStoreTypeError: Bool = false
    @Published  var selectStatError: Bool = false
    @Published  var taxPercentageRequiredError: Bool = false
    var counties: [String] = ["NC"]
    
    init() {
        loadCountries()
    }
    func createStore() {
        validateInputs()
    }
    func validateInputs() {
        imageUploadError = true ? selectedImage == nil : false
        emailError = email.isEmpty || !isValidEmail(email)
        storeNameError = storeName.isEmpty
        cityError = city.isEmpty
        pincodeError = pincode.isEmpty || !isValidPincode(pincode)
        addressError = address.isEmpty
        countyError = county.isEmpty
        taxPercentageRequiredError = taxPercentageRequired.isEmpty
    }

    // Helper method to validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // Helper method to validate pincode length
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
