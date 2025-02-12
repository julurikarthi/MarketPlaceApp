//
//  API.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//

import Foundation

extension String {
    static let baseURL = "https://18.188.42.21/api"
    
    static func createUser() -> String {
        return "\(baseURL)/createUser/"
    }

    static func login() -> String {
        return "\(baseURL)/login/"
    }

    static func createStore() -> String {
        return "\(baseURL)/createStore/"
    }

    static func getAllStores() -> String {
        return "\(baseURL)/getAllStores/"
    }

    static func getStoreDetails() -> String {
        return "\(baseURL)/storeDetails/"
    }

    static func getStoreCategories() -> String {
        return "\(baseURL)/getstoreCategories/"
    }

    static func createProduct() -> String {
        return "\(baseURL)/createProduct/"
    }

    static func getAllProductbyStore() -> String {
        return "\(baseURL)/getAllProductbyStore/"
    }

    static func getPublishedProducts() -> String {
        return "\(baseURL)/getAllPublishedProducts/"
    }

    static func updateProduct() -> String {
        return "\(baseURL)/updateProduct/"
    }

    static func deleteProduct() -> String {
        return "\(baseURL)/deleteProduct/"
    }

    static func createCart() -> String {
        return "\(baseURL)/createCart/"
    }

    static func getCart() -> String {
        return "\(baseURL)/getCart/"
    }
    
    static func getDashboardData() -> String {
        return "\(baseURL)/getDashboardData/"
    }
    
    static func getproductDetails() -> String {
        return "\(baseURL)/getproductDetails/"
    }

    static func updateCart() -> String {
        return "\(baseURL)/updateCart/"
    }

    static func deleteCartItem() -> String {
        return "\(baseURL)/deleteCartItem/"
    }

    static func getCartByStore() -> String {
        return "\(baseURL)/getCartByStore/"
    }

    static func createOrder() -> String {
        return "\(baseURL)/createOrder/"
    }

    static func updateOrder() -> String {
        return "\(baseURL)/updateOrder/"
    }

    static func getCustomerOrder() -> String {
        return "\(baseURL)/getCustomerOrder/"
    }

    static func getOrdersForStore() -> String {
        return "\(baseURL)/getOrdersForStore/"
    }

    static func createCategory() -> String {
        return "\(baseURL)/createCategory/"
    }

    static func getCategoryProductByStore() -> String {
        return "\(baseURL)/getCategoryProductByStore/"
    }

    static func createOffer() -> String {
        return "\(baseURL)/createOffer/"
    }

    static func getStoreOffers() -> String {
        return "\(baseURL)/getStoreOffers/"
    }

    static func getAllOffers() -> String {
        return "\(baseURL)/getAllOffers/"
    }
    
    static func getOffersByStore() -> String {
        return "\(baseURL)/getOffersByStore/"
    }

    static func deleteOffer() -> String {
        return "\(baseURL)/deleteOffer/"
    }

    static func uploadImage() -> String {
        return "\(baseURL)/uploadImage/"
    }

    static func downloadImage(imageid: String) -> String {
        return "\(baseURL)/downloadImage/?file_name=\(imageid)"
    }
    
    static func generateUniqueFileName(originalFileName: String) -> String {
        let uuid = UUID().uuidString
        let fileExtension = (originalFileName as NSString).pathExtension
        return fileExtension.isEmpty ? uuid : "\(uuid).\(fileExtension)"
    }
}
