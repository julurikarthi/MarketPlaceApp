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
    @Published var categories: [Category] = []
    @Published var newCategoryName: String = ""
    @Published var isAddingCategory: Bool = false
    @Published var showCetegoryProgressIndicator = false
    @Published var showProgressIndicator = false
    @Published var variants = [Variant]()
    @Published var search_tags = [String]()
    private var cancellables = Set<AnyCancellable>()
    private var isUpdateProduct: Bool = false
    private var product_id: String?

    func validateFields() -> Bool {
        if productName.isEmpty || description.isEmpty || stock.isEmpty || categoryID.categoryName.isEmpty || selectedPhotos.isEmpty {
            errorMessage = "All fields are required"
            showErrorMessage = true
            return false
        }
        if variants.isEmpty ||  price.isEmpty {
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
                                           isPublish: isPublished,
                                           variants: variants,
                                           search_tag: search_tags)
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
            ).receive(on: DispatchQueue.main).sink(
                receiveCompletion: { completion in
                    DispatchQueue.main.async {
                        self.showProgressIndicator = false
                    }
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
                                                    DispatchQueue.main.async {
                                                        self.categories = response.categories
                                                        self.showProgressIndicator = false
                                                    }
                                                }
                                             ).store(in: &cancellables)
    }
    
    func createCategory(name: String) {
        showCetegoryProgressIndicator = true
        let createcategoryRequest: CreateCategoryRequest = CreateCategoryRequest(category_name: name)
        NetworkManager.shared.performRequest(url: .createCategory(),
                                             method: .POST,
                                             payload: createcategoryRequest,
                                             responseType: CreateCategoryResponse.self).receive(on: DispatchQueue.main).sink(
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
        selectedImages_ids = product.imageids
        isPublished = product.isPublish
        categoryID = product.categoryID
        product_id = product.product_id
        isUpdateProduct = true
        variants = product.variants ?? []
        search_tags = product.search_tags ?? []
        downloadProductImages(imageIds: selectedImages_ids)
    }
    
    func downloadProductImages(imageIds: [String]) {
        self.showProgressIndicator = true
        let validImageIds = imageIds.filter { !$0.isEmpty }
        guard !validImageIds.isEmpty else {
            print("No valid image IDs found")
            return
        }

        let dispatchGroup = DispatchGroup()

        for imageID in validImageIds {
            let imageURL = String.downloadImage(imageid: imageID)

            if let cachedImage = ImageDownloader.shared.getCachedImage(for: imageURL) {
                selectedPhotos.append(cachedImage)
                continue
            }

            dispatchGroup.enter()
            NetworkManager.shared.downloadImage(from: imageURL)
                .tryMap { data -> UIImage in
                    guard let image = UIImage(data: data) else {
                        throw URLError(.cannotDecodeContentData)
                    }

                    let resizedImage = image.resized(toWidth: 500)
                    guard let compressedData = resizedImage.jpegData(compressionQuality: 0.8),
                          let finalImage = UIImage(data: compressedData) else {
                        throw URLError(.cannotDecodeContentData)
                    }

                    ImageDownloader.shared.cacheImage(finalImage, for: imageURL)
                    return finalImage
                }
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completionStatus in
                        switch completionStatus {
                        case .failure(let error):
                            print("Image download failed: \(error.localizedDescription)")
                        case .finished:
                            print("Download completed successfully")
                        }
                        dispatchGroup.leave()
                    },
                    receiveValue: { [weak self] downloadedImage in
                        guard let self = self else { return }
                        self.showProgressIndicator = false
                        selectedPhotos.append(downloadedImage)
                    }
                )
                .store(in: &self.cancellables) // Force unwrap is safe here since we check `self` before
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard self != nil else { return }
            print("Final downloaded images")
        }
    }


    func generateAIContent(description: String) {
        let apiKey = "AIzaSyDd3CtwAyACU4zqdAik8A6o9oByxC9DN0Y"
        let url = URL(string: "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": "Generate a compelling product description for: \(description)"]
                    ]
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let textParts = content["parts"] as? [[String: Any]],
                   let text = textParts.first?["text"] as? String {
                    print("Generated Description: \(text)")
                    self.description = text
                }
            }
        }.resume()
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
    let categoryID: Category
    let variants: [Variant]?
    let search_tags: [String]?
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
