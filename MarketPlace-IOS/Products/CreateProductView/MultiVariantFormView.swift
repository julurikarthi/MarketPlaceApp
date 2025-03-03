//
//  MultiVariantFormView.swift
//  MarketPlace-IOS
//
//  Created by karthik on 3/3/25.
//

import SwiftUI

struct NewVariant: Identifiable {
    var id = UUID()
    var variantType: String
    var variantValue: String
    var price: String
    var stock: String
    var customVariantType: String = "" // For custom variant type input
    var customSizeValue: String = ""   // For custom size input
    var customColorValue: String = ""  // For custom color input
}

struct MultiVariantFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var variants: [NewVariant] = []
    @State private var showSuccessMessage = false
    @State private var showErrorMessage = false
    @State private var errorMessage = ""
    @State private var isSaved = false // Track if variants have been saved
    
    // Predefined options
    private let variantTypes = ["Size", "Color", "Weight", "Custom"]
    private let sizeOptions = ["XS", "S", "M", "L", "XL", "Custom"]
    private let colorOptions = ["Red", "Blue", "Green", "Yellow", "Black", "White", "Custom"]
    private let stockOptions = ["50", "100", "200", "Custom"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Form {
                    Section(header: Text("Variant Details").font(.subheadline).foregroundColor(.black)) {
                        ForEach($variants) { $variant in
                            VStack(spacing: 15) {
                                // Variant Type Picker
                                Picker("Variant Type", selection: $variant.variantType) {
                                    ForEach(variantTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.vertical, 8)
                                .background(Color(.white))
                                .cornerRadius(8)
                                .disabled(isSaved) // Disable if saved
                                
                                // Custom Variant Type Input (only shown when "Custom" is selected)
                                if variant.variantType == "Custom" {
                                    TextField("Enter Custom Variant Type", text: $variant.customVariantType)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.subheadline)
                                        .disabled(isSaved) // Disable if saved
                                }
                                
                                // Variant Value Input
                                if variant.variantType == "Size" {
                                    Picker("Size", selection: $variant.variantValue) {
                                        ForEach(sizeOptions, id: \.self) { size in
                                            Text(size).tag(size)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding(.vertical, 8)
                                    .background(Color(.white))
                                    .cornerRadius(8)
                                    .disabled(isSaved) // Disable if saved
                                    
                                    // Custom Size Input (only shown when "Custom" is selected)
                                    if variant.variantValue == "Custom" {
                                        TextField("Enter Custom Size", text: $variant.customSizeValue)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.subheadline)
                                            .disabled(isSaved) // Disable if saved
                                    }
                                } else if variant.variantType == "Color" {
                                    Picker("Color", selection: $variant.variantValue) {
                                        ForEach(colorOptions, id: \.self) { color in
                                            Text(color).tag(color)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding(.vertical, 8)
                                    .background(Color(.white))
                                    .cornerRadius(8)
                                    .disabled(isSaved) // Disable if saved
                                    
                                    // Custom Color Input (only shown when "Custom" is selected)
                                    if variant.variantValue == "Custom" {
                                        TextField("Enter Custom Color", text: $variant.customColorValue)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.subheadline)
                                            .disabled(isSaved) // Disable if saved
                                    }
                                } else {
                                    TextField("Value (e.g., 1kg)", text: $variant.variantValue)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.subheadline)
                                        .disabled(isSaved) // Disable if saved
                                }
                                
                                // Price Input
                                TextField("Price ($)", text: $variant.price)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.subheadline)
                                    .disabled(isSaved) // Disable if saved
                                
                                // Stock Quantity Picker
                                Picker("Stock Quantity", selection: $variant.stock) {
                                    ForEach(stockOptions, id: \.self) { stock in
                                        Text(stock).tag(stock)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 8)
                                .disabled(isSaved) // Disable if saved
                                
                                // Custom Stock Input (only shown when "Custom" is selected)
                                if variant.stock == "Custom" {
                                    TextField("Enter Custom Stock Quantity", text: $variant.stock)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.subheadline)
                                        .disabled(isSaved) // Disable if saved
                                }
                                
                                // Remove Variant Button (always visible, even after saving)
                                Button(action: {
                                    withAnimation {
                                        removeVariant(id: variant.id)
                                    }
                                }) {
                                    Label("Remove Variant", systemImage: "trash")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                                .padding(.top, 5)
                            }
                            .padding()
                            .background(Color(.white))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        
                        // Add Variant Button (hidden if saved)
                        if !isSaved {
                            Button(action: addVariant) {
                                Label("Add New Variant", systemImage: "plus.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    
                    // Save Variants Button (hidden if saved)
                    if !isSaved {
                        Section {
                            Button(action: submitVariants) {
                                Text("Save Variants")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(variants.isEmpty ? Color.gray : Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                    .disabled(variants.isEmpty)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                // Success Message
                if showSuccessMessage {
                    Text("Variants Created Successfully!")
                        .foregroundColor(.green)
                        .bold()
                        .padding()
                        .transition(.opacity)
                }
                
                // Error Message
                if showErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                        .transition(.opacity)
                }
            }.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color.themeRed)
                }
            }.navigationTitle("Create Variant")
                
        }
    }
    
    // Adds a new empty variant
    func addVariant() {
        withAnimation {
            let newVariant = NewVariant(variantType: "Size", variantValue: "M", price: "", stock: "50")
            variants.append(newVariant)
        }
    }
    
    // Removes a variant by ID
    func removeVariant(id: UUID) {
        withAnimation {
            variants.removeAll { $0.id == id }
        }
    }
    
    // Submits the variant data
    func submitVariants() {
        // Reset messages
        showSuccessMessage = false
        showErrorMessage = false
        errorMessage = ""
        
        // Validate each variant
        for variant in variants {
            let finalVariantType = variant.variantType == "Custom" ? variant.customVariantType : variant.variantType
            let finalVariantValue: String
            
            if variant.variantType == "Size" {
                finalVariantValue = variant.variantValue == "Custom" ? variant.customSizeValue : variant.variantValue
            } else if variant.variantType == "Color" {
                finalVariantValue = variant.variantValue == "Custom" ? variant.customColorValue : variant.variantValue
            } else {
                finalVariantValue = variant.variantValue
            }
            
            // Check if all fields are filled
            if finalVariantType.isEmpty {
                errorMessage = "Please enter a variant type for all variants."
                showErrorMessage = true
                return
            }
            if finalVariantValue.isEmpty {
                errorMessage = "Please enter a variant value for all variants."
                showErrorMessage = true
                return
            }
            if variant.price.isEmpty || Double(variant.price) == nil {
                errorMessage = "Please enter a valid price for all variants."
                showErrorMessage = true
                return
            }
            if variant.stock.isEmpty || Int(variant.stock) == nil {
                errorMessage = "Please enter a valid stock quantity for all variants."
                showErrorMessage = true
                return
            }
        }
        
        // If all validations pass, mark as saved
        withAnimation {
            isSaved = true
            showSuccessMessage = true
        }
    }
}

struct MultiVariantFormView_Previews: PreviewProvider {
    static var previews: some View {
        MultiVariantFormView()
    }
}
