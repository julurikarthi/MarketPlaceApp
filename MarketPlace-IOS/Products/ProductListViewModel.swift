//
//  ProductListViewModel.swift
//  MarketPlace-IOS
//
//  Created by karthik on 1/27/25.
//

import SwiftUI
import Combine

protocol ProductListViewModelDelegate: AnyObject {
    func didtapOnEditButton(for product: EditProduct)
    func didtapOnDeleteButton(for product: GetAllStoreProductsResponse.Product)
}


class ProductListViewModel: ObservableObject {
    @Published var showAddProductView: Bool = false
    @MainThreadPublished var showProgressIndicator = false
    @Published var categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    @Published var storeProductsbyCategories: GetAllStoreProductsResponse = .init(products: [])
    var selectedCategory: Category?
    var editProduct: EditProduct? = nil
    func getstoreCategories() async -> Bool {
        return await withCheckedContinuation { continuation in
            showProgressIndicator = true
            let fetchcategoryRequest: FetchCategoryRequest = .init()

            NetworkManager.shared.performRequest(
                url: .getStoreCategories(),
                method: .POST,
                payload: fetchcategoryRequest,
                responseType: CategoriesResponse.self
            ).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Request completed successfully.")
                    case .failure(let error):
                        print("Request failed: \(error.localizedDescription)")
                        continuation.resume(returning: false) // Indicate failure
                    }
                },
                receiveValue: { response in
                    DispatchQueue.main.async {
                        self.categories = response.categories
                        continuation.resume(returning: true) // Indicate success
                    }
                }
            ).store(in: &cancellables)
        }
    }

    func getAllProductbyStore(category_id: String = "", page: Int = 1) async {
        showProgressIndicator = true
        let request = GetAllProductByStoreRequest(category_id: category_id.isEmpty ? categories.first?.categoryID : category_id, page: page)
        NetworkManager.shared.performRequest(
            url: .getAllProductbyStore(),
            method: .POST,
            payload: request,
            responseType: GetAllStoreProductsResponse.self
        ).sink(
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
                        self.showProgressIndicator = false
                        self.storeProductsbyCategories = response
                    }
                }
            ).store(in: &cancellables)
    }
    
}

extension ProductListViewModel: ProductListViewModelDelegate {
    
    func didtapOnEditButton(for product: EditProduct) {
        showAddProductView = true
        self.editProduct = product
    }
    
    func didtapOnDeleteButton(for product: GetAllStoreProductsResponse.Product) {
        
    }
}
