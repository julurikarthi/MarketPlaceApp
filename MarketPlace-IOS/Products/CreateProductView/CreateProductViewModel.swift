//
//  CreateProductViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/24/25.
//

import SwiftUI
import Foundation
import Combine
class CreateProductViewModel: ObservableObject {
    @Published var createProductResponse: CreateProductResponse?
    @Published var isLoading: Bool = false
    @Published var allStoreProducts: GetAllStoreProductsResponse?
    @Published var successResponse: Bool = false
    
    @Published var productName: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var stock: String = ""
    @Published var categoryID: Category = .init(categoryID: "", categoryName: "", createdAt: "", updatedAt: "")
    @Published var storeID: String = ""
    @Published var taxPercentage: String = ""
    @Published var selectedPhotos: [UIImage] = []
    @Published var selectedImages_ids: [String] = []
    @Published var showPhotoPicker: Bool = false
    @Published var isSubmitting: Bool = false
    @Published var showErrorMessage: Bool = false
    @Published var errorMessage: String = ""
    @Published var newCategoryNameError: String = "Please Enter the Category Name"
    @Published var isPublished: Bool = true
    @MainThreadPublished var categories: [Category] = []
    @MainThreadPublished var newCategoryName: String = ""
    @MainThreadPublished var isAddingCategory: Bool = false
    @MainThreadPublished var showCetegoryProgressIndicator = false
    @MainThreadPublished var showProgressIndicator = false
    private var cancellables = Set<AnyCancellable>()
    private var isUpdateProduct: Bool = false
    private var product_id: String?

    func validateFields() -> Bool {
        if productName.isEmpty || description.isEmpty || price.isEmpty || stock.isEmpty || categoryID.categoryName.isEmpty || selectedPhotos.isEmpty {
            errorMessage = "All fields are required"
            showErrorMessage = true
            return false
        }
        return true
    }
    
    func submitProduct() {
        guard validateFields() else { return }
        let request = CreateProductRequest(product_id: product_id,
                                           store_type: UserDetails.store_type,
                                           product_name: productName,
                                           description: description,
                                           price: Double(price)!,
                                           stock: Int(stock)!,
                                           category_id: categoryID.categoryID,
                                           imageids: selectedImages_ids,
                                           isPublish: isPublished)
        sendCreateProductRequest(request: request)
        
    }
    func addNewCategory() {
        guard !newCategoryName.isEmpty else { return }
        createCategory(name: newCategoryName)
        
    }
    
    func sendCreateProductRequest(request: CreateProductRequest) {
        let url = isUpdateProduct ? String.updateProduct() : String.createProduct()
        showProgressIndicator = true
        if isUpdateProduct {
            NetworkManager.shared.performRequest(
                url: url,
                method: .POST,
                payload: request,
                responseType: SuccessResponse.self
            ).sink(
                receiveCompletion: { completion in
                    self.showProgressIndicator = false
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    DispatchQueue.main.async {
                        self.showProgressIndicator = false
                        self.successResponse = true
                    }
                }
            ).store(in: &cancellables)
        } else {
            NetworkManager.shared.performRequest(
                url: url,
                method: .POST,
                payload: request,
                responseType: CreateProductResponse.self
            ).sink(
                receiveCompletion: { completion in
                    self.showProgressIndicator = false
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                    }
                },
                receiveValue: { response in
                    DispatchQueue.main.async {
                        self.showProgressIndicator = false
                        self.successResponse = true
                    }
                }
            ).store(in: &cancellables)
        }
        
    }
    
    func getstoreCategories() {
        showProgressIndicator = true
        let fetchcategoryRequest: FetchCategoryRequest = .init()
        NetworkManager.shared.performRequest(url: .getStoreCategories(),
                                             method: .POST,
                                             payload: fetchcategoryRequest,
                                             responseType: CategoriesResponse.self).sink(
                                                receiveCompletion: { completion in
                                                    switch completion {
                                                    case .finished:
                                                        print("Request completed successfully.")
                                                    case .failure(let error):
                                                        print("Request failed: \(error.localizedDescription)")
                                                    }
                                                },
                                                receiveValue: { response in
                                                    self.categories = response.categories
                                                    self.showProgressIndicator = false
                                                }
                                             ).store(in: &cancellables)
    }
    
    func createCategory(name: String) {
        showCetegoryProgressIndicator = true
        let createcategoryRequest: CreateCategoryRequest = CreateCategoryRequest(category_name: name)
        NetworkManager.shared.performRequest(url: .createCategory(),
                                             method: .POST,
                                             payload: createcategoryRequest,
                                             responseType: CreateCategoryResponse.self).sink(
                                                receiveCompletion: { completion in
                                                    switch completion {
                                                    case .finished:
                                                        print("Request completed successfully.")
                                                    case .failure(let error):
                                                        print("Request failed: \(error.localizedDescription)")
                                                    }
                                                },
                                                receiveValue: { response in
                                                    self.categories.append(.init(categoryID: response.categoryID, categoryName: response.categoryName, createdAt: nil, updatedAt: nil))
                                                    self.newCategoryName = ""
                                                    self.isAddingCategory = false
                                                    self.showCetegoryProgressIndicator = false
                                                    
                                                }
                                             ).store(in: &cancellables)
    }
    
    func updateProduct(product: EditProduct) {
        productName = product.product_name
        description = product.description
        price = "\(product.price)"
        stock = "\(product.stock)"
        selectedPhotos = product.selectedPhotos
        selectedImages_ids = product.imageids
        isPublished = product.isPublish
        categoryID = product.categoryID
        product_id = product.product_id
        isUpdateProduct = true
    }
    
}

struct EditProduct: RequestBody {
    let product_id: String
    let product_name: String
    let description: String
    let price: Double
    let stock: Int
    let imageids: [String]
    let isPublish: Bool
    let selectedPhotos: [UIImage]
    let categoryID: Category
}

struct FetchCategoryRequest: Codable, RequestBody {

}

struct CategoriesResponse: Codable {
    let categories: [Category]
}

struct Category: Codable, Hashable {
    let categoryID: String
    let categoryName: String
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case categoryID = "category_id"
        case categoryName = "category_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct CreateCategoryRequest: Codable, RequestBody {
    let category_name: String
}

struct CreateCategoryResponse: Codable {
    let message: String
    let categoryID: String
    let storeID: String
    let categoryName: String

    enum CodingKeys: String, CodingKey {
        case message
        case categoryID = "category_id"
        case storeID = "store_id"
        case categoryName = "category_name"
    }
}
