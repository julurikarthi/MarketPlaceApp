import SwiftUI
import PhotosUI

struct CreateProductView: View {
    @StateObject private var viewModel = CreateProductViewModel()

    let columns = [GridItem(.adaptive(minimum: 100))]
    @Environment(\.presentationMode) var presentationMode // For manual back action

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
                            TextFieldWithError(
                                title: "Description",
                                text: $viewModel.description,
                                errorMessage: $viewModel.errorMessage,
                                showError: viewModel.showErrorMessage && viewModel.description.isEmpty,
                                height: 150
                            )
                            TextFieldWithError(
                                title: "Price",
                                text: $viewModel.price,
                                errorMessage: $viewModel.errorMessage,
                                showError: viewModel.showErrorMessage && viewModel.price.isEmpty,
                                keyboardType: .decimalPad
                            )
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

                    Divider()

                    // Publish Toggle
                    Toggle("Publish", isOn: $viewModel.isPublished)
                        .padding(.horizontal)
                }.loadingIndicator(isLoading: $viewModel.showProgressIndicator)
                .padding(.bottom)
            }.task {
                viewModel.getstoreCategories()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Create Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Add "Create Product" button to the navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.submitProduct) {
                       
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
            }.navigationBarBackButtonHidden(true)
        }
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
            if height != nil {
                
                ZStack(alignment: .bottomLeading) {
                    TextField("", text: $text)
                        .keyboardType(keyboardType)
                        .padding()
                        .frame(height: 150)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    if text.isEmpty {
                        Text("Enter \(title)")
                            .foregroundColor(Color(hex: "#C5C5C7"))
                            .padding(.leading, 11)
                            .padding(.bottom, 10)
                    }
                   
                }
               
            } else {
                TextField("Enter \(title)", text: $text)
                    .keyboardType(keyboardType)
                    .padding()
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
    @Binding var selectedCategory: String
    @State private var showAddCategorySheet = false
    @ObservedObject var viewModel: CreateProductViewModel

    var body: some View {
        VStack {
            HStack {
                Text("Select Category")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Menu {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button(category.categoryName) {
                            selectedCategory = category.categoryName
                        }
                    }
                    Button(action: {
                        showAddCategorySheet.toggle()
                    }) {
                        Text("Add New Category")
                            .foregroundColor(.blue)
                    }
                } label: {
                    Text(selectedCategory.isEmpty ? "Select Category" : selectedCategory).bold()
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding()
                .background(.green).cornerRadius(10)
            }
            // Add New Category Sheet
            .sheet(isPresented: $showAddCategorySheet) {
                NavigationView {
                    VStack {
                        Text("Create a New Category")
                            .font(.headline)
                            .padding(.bottom, 10)
                            .foregroundColor(.primary)

                        // Use the TextFieldWithError for category input
                        TextFieldWithError(title: "Category Name", text: $viewModel.newCategoryName, errorMessage: $viewModel.newCategoryNameError, showError: false, keyboardType: .default)

                        Button(action: {
                            if !$viewModel.newCategoryName.wrappedValue.isEmpty {
                                viewModel.addNewCategory()
                                showAddCategorySheet = false
                            }
                        }) {
                            Text("Save Category")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(viewModel.newCategoryName.isEmpty ? Color.gray : Color.black)
                                .cornerRadius(8)
                                .disabled(viewModel.newCategoryName.isEmpty)
                        }
                        .padding(.top)

                        Spacer()
                    }.loadingIndicator(isLoading: $viewModel.showCetegoryProgressIndicator)
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showAddCategorySheet = false
                            }
                            .foregroundColor(Color.themeRed)
                        }
                    }
                }
            }
        }
    }
}



struct CreateProduct_Previews: PreviewProvider {
    static var previews: some View {
        CreateProductView()
    }
}
