import SwiftUI
import PhotosUI


struct Variant: Identifiable, Codable {
    var id: UUID? = UUID()
    var variant_type: String
    var value: String
    var price: Double
    var stock: Int
}


struct CreateProductView: View {
    @StateObject private var viewModel = CreateProductViewModel()
    @Binding var editProduct: EditProduct?
    let columns = [GridItem(.adaptive(minimum: 100))]
    @Environment(\.presentationMode) var presentationMode
    @State private var newVariantType: String = ""
    @State private var newPrice: String = ""
    @State private var newStock: String = ""
    @State private var isAddingVariant = false
    
    @State private var variantTypeError: String?
    @State private var priceError: String?
    @State private var stockError: String?
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Add Image Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Product Images")
                            .font(.headline).padding(.top, 10)

                        Button(action: {
                            viewModel.showPhotoPicker = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title2)
                                Text("Add Images")
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .background(Color.black)
                            .cornerRadius(8)
                        }
                        .sheet(isPresented: $viewModel.showPhotoPicker) {
                            ImagePicker(image: $viewModel.selectedPhotos,
                                        image_id: $viewModel.selectedImages_ids,
                                        isProgress: $viewModel.showProgressIndicator)
                        }

                        if !viewModel.selectedPhotos.isEmpty {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(viewModel.selectedPhotos, id: \.self) { image in
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                            )

                                        // Delete button
                                        Button(action: {
                                            if let index = viewModel.selectedPhotos.firstIndex(of: image) {
                                                viewModel.selectedPhotos.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .background(Circle().fill(Color.white).shadow(radius: 1))
                                        }
                                        .padding(4)
                                        .padding(.top, -8)
                                        .padding(.trailing, -8)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }

                    }
                    .padding(.horizontal)

                    Divider()

                    // Form Section
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            TextFieldWithError(
                                title: "Product Name",
                                text: $viewModel.productName,
                                errorMessage: $viewModel.errorMessage,
                                showError: viewModel.showErrorMessage && viewModel.productName.isEmpty
                            )
                            ZStack(alignment: .bottomTrailing) { // Change alignment to bottomTrailing
                                TextFieldWithError(
                                    title: "Description",
                                    text: $viewModel.description,
                                    errorMessage: $viewModel.errorMessage,
                                    showError: viewModel.showErrorMessage && viewModel.description.isEmpty,
                                    height: 150
                                )

                                Button(action: {
                                    if !viewModel.productName.isEmpty, viewModel.description.isEmpty {
                                        viewModel.generateAIContent(description: viewModel.productName)
                                    } else {
                                        if !viewModel.description.isEmpty {
                                            viewModel.generateAIContent(description: viewModel.description)
                                        }
                                    }
                                }) {
                                    Image("chatgpticon")
                                        .resizable()
                                        .frame(width: 24, height: 24) // Slightly bigger for better UI
                                        .padding(8)
                                        .background(Color.white.opacity(0.8)) // Optional background for visibility
                                        .clipShape(Circle()) // Make it circular
                                        .shadow(radius: 2) // Add a shadow for depth
                                }
                                .padding(.trailing, 10) // Adjust right padding
                                .padding(.bottom, 10) // Adjust bottom padding
                            }

                            if viewModel.variants.isEmpty {
                                TextFieldWithError(
                                    title: "Price",
                                    text: $viewModel.price,
                                    errorMessage: $viewModel.errorMessage,
                                    showError: viewModel.showErrorMessage && viewModel.price.isEmpty,
                                    keyboardType: .decimalPad
                                )
                            }
                            TextFieldWithError(
                                title: "Stock Quantity",
                                text: $viewModel.stock,
                                errorMessage: $viewModel.errorMessage,
                                showError: viewModel.showErrorMessage && viewModel.stock.isEmpty,
                                keyboardType: .numberPad
                            )
                            CategorySelectionView(selectedCategory: $viewModel.categoryID, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let variantTypeError = variantTypeError {
                        Text(variantTypeError).font(.caption)
                                                   .foregroundColor(.red)
                    }
                    if viewModel.variants.isEmpty {
                        Button(action: {
                            isAddingVariant = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Variant")
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    } else {
                        Button(action: {
                            isAddingVariant = true
                        }) {
                            HStack {
                                Text("\(viewModel.variants.count) Variants")
                                    .bold()
                                Spacer()
                                Image(systemName: "chevron.right") // Right arrow indicator
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }

                    HorizontalTextFieldView(savedTexts: $viewModel.search_tags)
                    Divider()
                    Toggle("Publish", isOn: $viewModel.isPublished)
                        .padding(.horizontal)
                }.loadingIndicator(isLoading: $viewModel.showProgressIndicator)
                .padding(.bottom)
            }.sheet(isPresented: $isAddingVariant) {
                MultiVariantFormView(variants: $viewModel.variants)
            }.task {
                viewModel.getAllCategories()
            }.onTapGesture {
                dismissKeyboard()
            }.onAppear {
                if let product = editProduct {
                    viewModel.updateProduct(product: product)
                }
            }.onChange(of: viewModel.successResponse, { _, _ in
                presentationMode.wrappedValue.dismiss()
            })
            .background(.white)
            .toolbar {
                // Add "Create Product" button to the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.submitProduct) {
                        Text("Save").foregroundColor(Color.themeRed)
                    }
                    .disabled(viewModel.isSubmitting)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss() // Custom back action
                    }) {
                        Image(systemName: "chevron.left") // Back arrow
                            .foregroundColor(Color.themeRed) // Custom back button color
                            .font(.title2) // Customize size
                    }
                }
            }
        }.navigationTitle("Create Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white, for: .navigationBar) // Set background to white
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar) // Ensures black text
    }
    
    
}

struct HorizontalTextFieldView: View {
    @State private var inputText: String = ""
    @Binding var savedTexts: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // ✅ Display Saved Texts Above the Input Field
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(savedTexts, id: \.self) { text in
                        Text(text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .transition(.scale) // Add a transition for when items are added
                    }
                }
                .padding(.vertical, 4)
            }
            .animation(.easeInOut, value: savedTexts) // Animate changes to savedTexts

            HStack(spacing: 12) {
                TextField("Enter search tag...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)

                Button(action: {
                    let trimmedText = inputText.trimmingCharacters(in: .whitespaces)
                    if !trimmedText.isEmpty {
                        withAnimation {
                            savedTexts.append(trimmedText)
                        }
                        inputText = ""
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                        .shadow(color: .green.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty) // Disable button if input is empty
                .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1)
            }
        }
        .padding()
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

struct TextFieldWithError: View {
    let title: String
    @Binding var text: String
    @Binding var errorMessage: String
    var showError: Bool
    var keyboardType: UIKeyboardType = .default
    var height: CGFloat?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            if let height = height { // Multi-line TextEditor
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $text)
                        .frame(height: height)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    if text.isEmpty { // Placeholder
                        Text("Enter \(title)")
                            .foregroundColor(Color(hex: "#C5C5C7"))
                            .padding(.horizontal, 14)
                            .padding(.top, 14)
                            .allowsHitTesting(false) // Doesn't block typing
                    }
                    
                    // Clear button
                    if !text.isEmpty {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            } else { // Single-line TextField with clear button
                HStack {
                    TextField("Enter \(title)", text: $text)
                        .keyboardType(keyboardType)
                        .padding()
                    
                    if !text.isEmpty {
                        Button(action: {
                            text = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            
            if showError {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color(hex: "#B70F01"))
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(Color(hex: "#BB1B0D"))
                }
                .transition(.opacity)
            }
        }
    }
}


struct CategorySelectionView: View {
    @Binding var selectedCategory: Category
    @State var selectednewCategory: ChildCategory?
    @State private var showAddCategorySheet = false
    @ObservedObject var viewModel: CreateProductViewModel
    
 
    var body: some View {
        VStack(spacing: 16) {
            // Category Selection Button
            HStack {
                Text((selectednewCategory?.name.isEmpty ?? true) ? "Select Category" : selectednewCategory?.name ?? "")
                    .font(.headline)
                    .foregroundColor(.primary) // You can adjust the text color if needed
                   
                
                Spacer() // Pushes the arrow to the right
                
                Image(systemName: "arrow.right.circle.fill") // Right arrow icon
                    .font(.title) // Adjust the size of the arrow
                    .foregroundColor(.blue) // Adjust the arrow color
            }
            .padding() // Add padding to the HStack to make it look more spacious
            .background(Color(.systemGray6)) // Background color for the button
            .cornerRadius(10) // Rounded corners
        }.onTapGesture {
            withAnimation(.easeInOut) {
                showAddCategorySheet = true
            }
        }
        .sheet(isPresented: $showAddCategorySheet) {
            if let newCategories = viewModel.newCategories {
                TestContentView(sampleCategories: newCategories.categories) { childCategory in
                    selectednewCategory = childCategory
                    showAddCategorySheet = false // Close the sheet after selection
                }
            }
        }
        .onAppear {
            UserDetails.requestCameraPermission()
            UserDetails.requestPhotoLibraryPermission()
        }
    }
}


extension View {
    func globalBackground(_ color: Color) -> some View {
        self
            .background(color)
            .edgesIgnoringSafeArea(.all)
    }
}
