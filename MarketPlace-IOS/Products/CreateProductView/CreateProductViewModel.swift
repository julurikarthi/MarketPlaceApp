//
//  CreateProductViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/24/25.
//

import SwiftUI
import Foundation
class CreateProductViewModel: ObservableObject {
    @Published var createProductResponse: CreateProductResponse?
    @Published var isLoading: Bool = false
    @Published var allStoreProducts: GetAllStoreProductsResponse?
    @Published var successResponse: SuccessResponse?
    
    @Published var productName: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var stock: String = ""
    @Published var categoryID: String = ""
    @Published var storeID: String = ""
    @Published var taxPercentage: String = ""
    @Published var selectedPhotos: [UIImage] = []
    @Published var showPhotoPicker: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = ""
    @Published var newCategoryNameError: String = "Please Enter the Category Name"
    @Published var isPublished: Bool = false
    @Published var categories: [String] = [] // Sample categories
    @Published var newCategoryName: String = ""
    @Published var isAddingCategory: Bool = false
    
    func validateFields() -> Bool {
        if productName.isEmpty || description.isEmpty || price.isEmpty || stock.isEmpty || categoryID.isEmpty || storeID.isEmpty || taxPercentage.isEmpty {
            errorMessage = "All fields are required"
            showErrorMessage = true
            return false
        }
        return true
    }
    
    func submitProduct() {
        guard validateFields() else { return }
        isSubmitting = true
        showErrorMessage = false
        
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSubmitting = false
            print("Product successfully submitted!")
        }
    }
    func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        categories.append(newCategoryName)
        categoryID = newCategoryName
        newCategoryName = ""
        isAddingCategory = false
    }
    
    func sendCreateProductRequest(request: CreateProductRequest, isUpdateProduct: Bool) {
        guard let url = URL(string: isUpdateProduct ? .updateProduct() : .createProduct()) else { return }
        
        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: CreateProductResponse.self
        )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    self.createProductResponse = response
                }
            )
    }
    
    func getAllProductbyStore(request: GetAllProductByStoreRequest) {
        guard let url = URL(string: .getAllProductbyStore()) else { return }
        
        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: GetAllStoreProductsResponse.self
        )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    self.allStoreProducts = response
                }
            )
    }
    
    func deleteProduct(request: DeleteProductRequest) {
        guard let url = URL(string: .deleteProduct()) else { return }
        
        let cancellable = NetworkManager.shared.performRequest(
            url: .login(),
            method: .POST,
            payload: request,
            responseType: SuccessResponse.self
        )
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    self.successResponse = response
                }
            )
    }
    
    
    
}
