//
//  LoginView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI

extension String {
    static let signupText = "By tapping creating Store"
    static let selectSericeText = "Select Service Type"
    static let selectStoreText = "Select Store Type"
    static let pickup = "Pickup"
    static let payAtPickup = "Pay at Pickup"
    static let delivery = "Delivery"
    static let firstNameRequired = "First name is required"
    static let lastNameRequired = "Last name is required"
    static let firstName = "First Name"
    static let lastName = "Last Name"
    static let emailRequired = "Email is required"
    static let pincodeRequired = "Pincode is required"
    static let addressRequired = "Address Required"
    static let cityRequired = "city is Required"
    static let email = "Email"
    static let mobile = "Mobile"
    static let storeType = "Store type"
    static let state = "State"
    static let singnUP = "Continue"
    static let createStoreText = "Create Store"
    static let address = "Enter Address"
    static let city = "City"
    static let pincode = "Pincode"
    static let mobileNumberRequired = "Mobile Number Required"
}

struct CreateStoreView: View {
    @StateObject var viewModel = SignUPModel()
    var storeTypes = ["Select Store type","Grocery", "Grocery", "Grocery"]
    @State private var dropdownselecton: String = "Select Store type"
    @State private var dropdownServiceSelection: String = "Select Service type"
    @State private var isPickup = false
    @State private var isPayAtPickup = false
    @State private var isDelivery = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack {
                        HStack(spacing: 10) {
                            CustomTextField(text: $viewModel.firstName, placeholder: .empty, isError: $viewModel.firstNameError, errorMessage: .firstNameRequired, title: .firstName)
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                            CustomTextField(text: $viewModel.lastName, placeholder: .empty, isError: $viewModel.lastNameError, errorMessage: .lastNameRequired, title: .lastName)
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                        }.padding([.trailing, .leading], 10)
                        
                        CustomTextField(text: $viewModel.email, placeholder: .empty, isError: $viewModel.emailError, errorMessage: .emailRequired, title: .email)
                            .frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.address, placeholder: .empty, isError: $viewModel.addressError, errorMessage: .addressRequired, title: .address)
                            .frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.city, placeholder: .empty, isError: $viewModel.cityError, errorMessage: .cityRequired, title: .city)
                            .frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.pincode, placeholder: .empty, isError: $viewModel.pincodeError, errorMessage: .pincodeRequired, title: .pincode)
                            .frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        
                        CustomTextField(text: $viewModel.selectStateText, placeholder: .empty, isError: $viewModel.selectStateTextError, errorMessage: .selectStoreText, title: .state, isDropdown: true, dropdownOptions: storeTypes).padding([.trailing, .leading], 20)
                        
                        
                        HStack(spacing: 10) {
                            DropdownPicker()
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .padding(.bottom, 14)
                            CustomTextField(text: $viewModel.mobile, placeholder: .empty, isError: $viewModel.mobileError, errorMessage: .mobileNumberRequired, title: .mobile, erroriconrequired: false)
                                .frame(width: UIScreen.main.bounds.width * 0.65)
                        }.padding([.trailing, .leading], 10)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            CustomTextField(text: $dropdownselecton, placeholder: .empty, isError: $viewModel.selectStoreTextError, errorMessage: .selectStoreText, title: .storeType, isDropdown: true, dropdownOptions: storeTypes)
                            Text(String.selectSericeText).font(.system(size: 15)).bold()
                            CheckboxView(isChecked: $isPickup, label: String.pickup)
                            CheckboxView(isChecked: $isPayAtPickup, label: String.payAtPickup)
                            CheckboxView(isChecked: $isDelivery, label: String.delivery)

                        }.padding([.leading, .trailing])
                        
                        Text(String.signupText)
                            .foregroundColor(.gray)
                            .font(.system(size: 10))
                            .lineLimit(3)
                            .padding([.top], 5)
                            .padding([.leading, .trailing], 15)
                        
                        signupButton
                    }
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    var signupButton: some View {
        Button(action: {
            // Add your button action here
            print("Create Store")
        }) {
            Text(String.createStoreText) // Correct placement of the text
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 3)
                .padding()
                .background(Color.red)
                .cornerRadius(20)
        }.padding(15)
    }

    
}


struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    @Binding var isError: Bool
    var errorMessage: String
    var title: String
    var erroriconrequired = true
    @State private var isFocused: Bool = false
    var isDropdown: Bool = false
    var dropdownOptions: [String] = []
    var keyPadType = UIKeyboardType.default
    var isPhoneNumber = false
    /// segment controller
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.system(size: 15)).bold()
            
            if isDropdown {
                Picker(selection: $text, label: Text(String.selectSericeText)) {
                    ForEach(dropdownOptions, id: \.self) { option in
                        Text(option).font(.system(size: 10)).tag(option)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 3)
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(isFocused ? Color.white : Color(hex: "#F7F7F7"))
                .cornerRadius(10.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(isFocused ? Color.black : (isError ? Color(hex: "#B70F01") : Color.clear),
                                      style: StrokeStyle(lineWidth: 2.0))
                )
                .accentColor(.black)
            } else {
                TextField(placeholder, text: $text, onEditingChanged: { isEditing in
                    self.isFocused = isEditing
                }).keyboardType(keyPadType)
                .onChange(of: text) { newValue in
                        if keyPadType == .numberPad && isPhoneNumber {
                            text = formatPhoneNumber(text)
                        }
                }
                .padding()
                .frame(height: 35)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isFocused ? Color.white : Color(hex: "#F7F7F7"))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? Color.black : (isError ? Color(hex: "#B70F01") : Color.clear), lineWidth: 2)
                )
                .accentColor(.black)
                .foregroundColor(.black)
            }
            
            if isError && erroriconrequired {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color(hex: "#B70F01"))
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#BB1B0D"))
                }
                .transition(.opacity) 
            } else {
                HStack {
                    Spacer()
                }
                .frame(height: 10) // Fixed height
            }
        }.animation(.easeInOut, value: isFocused)
    }
    
    private func formatPhoneNumber(_ input: String) -> String {
        let numbersOnly = input.filter { $0.isNumber }
        var formatted = ""
        
        if numbersOnly.count > 0 {
            formatted += "("
            formatted += numbersOnly.prefix(3)
            if numbersOnly.count > 3 {
                formatted += ") "
                formatted += numbersOnly.dropFirst(3).prefix(3)
            }
            if numbersOnly.count > 6 {
                formatted += "-"
                formatted += numbersOnly.dropFirst(6).prefix(4)
            }
        }
        
        return formatted
    }
}


#Preview {
    CreateStoreView()
}


extension Color {
    init(hex: String) {
        // Remove '#' if present
        let cleanedHex = hex.replacingOccurrences(of: "#", with: "")
        
        // Ensure the hex code is 6 characters long
        let scanner = Scanner(string: cleanedHex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}

extension String {
    static let empty = ""
}


struct DropdownPicker: View {
    @State private var selectedOption: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Country").font(.system(size: 15)).bold()
            HStack {
                Text(selectedOption.isEmpty ? "+1 (US)" : selectedOption)
                    .foregroundColor(.black).font(.subheadline)
            }
            .padding()
            .frame(height: 35)
            .background(Color(hex: "#F7F7F7"))
            .cornerRadius(10)
        }
    }
}

struct RoundedButton: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
        }
        .frame(maxWidth: 200) // Set a fixed width if needed
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    var label: String

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isChecked ? .green : .gray)

                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button styling from affecting appearance
    }
}
