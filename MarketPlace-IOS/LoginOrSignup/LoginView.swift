//
//  LoginView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/19/25.
//

import SwiftUI

struct LoginView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var county: String = ""
    @State private var mobile: String = ""
    var storeTypes = ["Select Store type","Grocery", "Grocery", "Grocery"]
    var serviceTypes = ["Select Service type","Grocery", "Grocery", "Grocery"]
    @State private var dropdownselecton: String = "Select Store type"
    @State private var dropdownServiceSelection: String = "Select Service type"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack {
                        HStack(spacing: 10) {
                            CustomTextField(text: $firstName, placeholder: .empty, isError: false, errorMessage: "First name is required", title: "First Name")
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                            CustomTextField(text: $lastName, placeholder: .empty, isError: false, errorMessage: "Last name is required", title: "Last Name")
                                .frame(width: UIScreen.main.bounds.width * 0.45)
                        }.padding([.trailing, .leading], 10)
                        
                        CustomTextField(text: $email, placeholder: .empty, isError: false, errorMessage: "Email is required", title: "Email")
                            .frame(width: .infinity)
                            .padding([.trailing, .leading], 20)
                        
                        HStack(spacing: 10) {
                            DropdownPicker(dropdownOptions: serviceTypes)
                                .frame(width: UIScreen.main.bounds.width * 0.25)
                                .padding(.bottom, 14)
                            CustomTextField(text: $mobile, placeholder: .empty, isError: false, errorMessage: "", title: "Mobile", erroriconrequired: false)
                                .frame(width: UIScreen.main.bounds.width * 0.65)
                        }.padding([.trailing, .leading], 10)
                        
                        VStack(spacing: 10) {
                            CustomTextField(text: $dropdownselecton, placeholder: "Select Store type", isError: false, errorMessage: "Select Store type", title: "Store type", isDropdown: true, dropdownOptions: storeTypes)
                            CustomTextField(text: $dropdownServiceSelection, placeholder: "Select Service type", isError: false, errorMessage: "Select Service type", title: "Store type", isDropdown: true, dropdownOptions: serviceTypes)
                        }.padding([.leading, .trailing])
                        
                        Text("By tapping Sign UP, you Consent to receiving a one-time verification code via text message to this phone number. Message and data rates may apply")
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
            print("Sign Up button tapped")
        }) {
            Text("Sign Up") // Correct placement of the text
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
    var isError: Bool
    var errorMessage: String
    var title: String
    var erroriconrequired = true
    @State private var isFocused: Bool = false
    var isDropdown: Bool = false
    var dropdownOptions: [String] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.system(size: 15)).bold()
            
            if isDropdown {
                Picker(selection: $text, label: Text("Select Service type")) {
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
                })
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
}


#Preview {
    LoginView()
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
    var dropdownOptions: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Country").font(.system(size: 15)).bold()
            HStack {
                Text(selectedOption.isEmpty ? "+1 (US)" : selectedOption)
                    .foregroundColor(.black)
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
