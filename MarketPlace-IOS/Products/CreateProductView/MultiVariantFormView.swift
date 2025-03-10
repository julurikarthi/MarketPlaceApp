import SwiftUI


struct MultiVariantFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var variants: [Variant]
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
                                Picker("Variant Type", selection: $variant.variant_type) {
                                    ForEach(variantTypes, id: \.self) { type in
                                        Text(type).tag(type)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(.vertical, 8)
                                .background(Color(.white))
                                .cornerRadius(8)
                                .disabled(isSaved) // Disable if saved
                                
                                // Variant Value Input
                                if variant.variant_type == "Size" {
                                    Picker("Size", selection: $variant.value) {
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
                                    if variant.value == "Custom" {
                                        TextField("Enter Custom Size", text: $variant.value)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.subheadline)
                                            .disabled(isSaved) // Disable if saved
                                    }
                                } else if variant.variant_type == "Color" {
                                    Picker("Color", selection: $variant.value) {
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
                                    if variant.value == "Custom" {
                                        TextField("Enter Custom Color", text: $variant.value)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .font(.subheadline)
                                            .disabled(isSaved) // Disable if saved
                                    }
                                } else {
                                    TextField("Value (e.g., 1kg)", text: $variant.value)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.subheadline)
                                        .disabled(isSaved) // Disable if saved
                                }
                                
                                // Price Input
                                TextField("Price ($)", text: Binding(
                                    get: { variant.price == 0.0 ? "" : String(format: "%.2f", variant.price) },
                                    set: { newValue in
                                        variant.price = Double(newValue) ?? 0.0
                                    }
                                ))
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.subheadline)
                                .disabled(isSaved)

                                
                                // Stock Quantity Picker
                                Picker("Stock Quantity", selection: $variant.stock) {
                                    ForEach(stockOptions, id: \.self) { stock in
                                        Text(stock).tag(Int(stock) ?? 0)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical, 8)
                                .disabled(isSaved) // Disable if saved
                                
                                // Custom Stock Input (only shown when "Custom" is selected)
                                if variant.stock == 0 { // Assuming "Custom" maps to 0
                                    TextField("Enter Custom Stock Quantity", value: $variant.stock, format: .number)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.subheadline)
                                        .disabled(isSaved) // Disable if saved
                                }
                                
                                // Remove Variant Button (always visible, even after saving)
                                Button(action: {
                                    withAnimation {
                                        removeVariant(id: variant.id!)
                                    }
                                }) {
                                    Label("Remove Variant", systemImage: "trash")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                }
                                .padding(.top, 5).onTapGesture {
                                    removeVariant(id: variant.id!)
                                }
                            }
                            .padding()
                            .background(Color(.white))
                            .cornerRadius(10)
                            .shadow(radius: 2)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                
                            }
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
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if variants.filter({$0.price == 0}).count > 0 {
                            variants.removeAll()
                        }
                        dismiss()
                    }
                    .foregroundColor(Color.themeRed)
                }
            }
            .navigationTitle("Create Variant")
        }
    }
    
    // Adds a new empty variant
    func addVariant() {
        withAnimation {
            let newVariant = Variant(variant_type: "Size", value: "", price: 0.0, stock: 50)
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
            // Check if all fields are filled
            if variant.variant_type.isEmpty {
                errorMessage = "Please enter a variant type for all variants."
                showErrorMessage = true
                return
            }
            if variant.value.isEmpty {
                errorMessage = "Please enter a variant value for all variants."
                showErrorMessage = true
                return
            }
            if variant.price <= 0 {
                errorMessage = "Please enter a valid price for all variants."
                showErrorMessage = true
                return
            }
            if variant.stock <= 0 {
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
        
        // Print the saved variants (for debugging or API submission)
        print("Saved Variants: \(variants)")
       
         
        dismiss()
    }
}

