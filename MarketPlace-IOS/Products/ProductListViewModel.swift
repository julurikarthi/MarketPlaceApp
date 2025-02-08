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
    func didtapOnDeleteButton(for product: Product)
    func didtapProduct(for product: Product)
}


class ProductListViewModel: ObservableObject {
    @Published var showAddProductView: Bool = false
    @Published var moveToProductDetails: Bool = false
    @Published var seletectedProduct: Product = .init(product_id: "", store_id: "", product_name: "", price: 0, stock: 0, description: "", category_id: "", updatedAt: "", imageids: [])
    
    @Published var showProgressIndicator = false
    var categories: [Category] = []
    private var cancellables = Set<AnyCancellable>()
    @Published var storeProductsbyCategories: GetAllStoreProductsResponse = .init(products: [])
    var selectedCategory: Category?
    @Published var editProduct: EditProduct?
    func getstoreCategories(isCustomer: Bool = false) {
        DispatchQueue.main.async {
            self.showProgressIndicator = true
        }
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
                }
            },
            receiveValue: {  [weak self] response in
                self?.categories = response.categories
                self?.selectedCategory = response.categories.first
                if !(self?.categories.isEmpty ?? false) {
                    let categoryID = self?.selectedCategory?.categoryID ?? self?.categories.first?.categoryID ?? ""
                    self?.getAllProductbyStore(category_id: categoryID, isCustomer: isCustomer)
                } else {
                    DispatchQueue.main.async {
                        self?.showProgressIndicator = false
                    }
                }
            }
        ).store(in: &cancellables)
    }

    func getAllProductbyStore(category_id: String = "", page: Int = 1,
                              isCustomer: Bool = false) {
        DispatchQueue.main.async {
            self.showProgressIndicator = true
        }
        let request = GetAllProductByStoreRequest(category_id: category_id.isEmpty ? categories.first?.categoryID : category_id,
                                                  isPublish: true,
                                                  page: 1)
        NetworkManager.shared.performRequest(
            url: isCustomer ? .getPublishedProducts() : .getAllProductbyStore(),
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
                        self.storeProductsbyCategories = GetAllStoreProductsResponse(products: response.products)
                    }

                }
            ).store(in: &cancellables)
    }
    
}

extension ProductListViewModel: ProductListViewModelDelegate {
    
    func didtapProduct(for product: Product) {
        seletectedProduct = product
        moveToProductDetails = true
    }
    
    
    func didtapOnEditButton(for product: EditProduct) {
        self.editProduct = product
        showAddProductView = true
    }
    
    func didtapOnDeleteButton(for product: Product) {
        deleteProduct(product_id: product.product_id,
                      request: DeleteProductRequest(product_id: product.product_id))
    }
    
    func deleteProduct(product_id: String, request: DeleteProductRequest) {
        showProgressIndicator = true
          NetworkManager.shared.performRequest(
            url: .deleteProduct(),
            method: .POST,
            payload: request,
            responseType: SuccessResponse.self
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
                        self.deleteItem(product_id: product_id)
                        self.showProgressIndicator = false
                    }
                    
                }
            ).store(in: &cancellables)
    }
    
    func deleteItem(product_id: String) {
        // Find the index of the product to delete
        if let index = storeProductsbyCategories.products.firstIndex(where: { $0.product_id == product_id }) {
            // Remove the item at the found index
            storeProductsbyCategories.products.remove(at: index)
        }
    }

}

