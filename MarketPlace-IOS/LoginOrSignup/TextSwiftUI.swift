//
//  TextSwiftUI.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/22/25.
//

import SwiftUI
import PhotosUI
struct CreateStoreViewCopy: View {
    @State private var storeImage: UIImage?
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var city: String = ""
    @State private var pincode: String = ""
    @State private var isImagePickerPresented = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Upload Store Image
                    VStack {
                        Text("Upload Store Image")
                            .font(.headline)

                        if let image = storeImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Text("No Image Selected")
                                        .foregroundColor(.gray)
                                )
                        }

                        Button(action: {
                            isImagePickerPresented = true
                        }) {
                            Text("Select Image")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    // Email
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    }

                    // Address
                    VStack(alignment: .leading) {
                        Text("Address")
                            .font(.headline)
                        TextField("Enter address", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // City
                    VStack(alignment: .leading) {
                        Text("City")
                            .font(.headline)
                        TextField("Enter city", text: $city)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Pincode
                    VStack(alignment: .leading) {
                        Text("Pincode")
                            .font(.headline)
                        TextField("Enter pincode", text: $pincode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }

                    // Submit Button
                    Button(action: {
                        // Handle form submission
                        print("Store details submitted")
                    }) {
                        Text("Submit")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Create Store")
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $storeImage)
            }
        }
    }
}


#Preview(body: {
    CreateStoreViewCopy()
})
