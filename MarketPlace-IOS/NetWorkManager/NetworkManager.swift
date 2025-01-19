//
//  NetworkManager.swift
//  marketplace-app
//
//  Created by karthik on 1/18/25.
//


protocol NetworkManagerProtocol {
    /// Fetch data using a URLRequest
    /// - Parameter request: The URLRequest to execute
    /// - Returns: A publisher that emits data or an error
    func fetchData(with request: URLRequest) -> AnyPublisher<Data, Error>
}


import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    /// Generic method to perform API requests using Combine
    /// - Parameters:
    ///   - url: API endpoint URL
    ///   - method: HTTP method (e.g., "POST")
    ///   - payload: Request body as a generic type conforming to `Encodable`
    ///   - responseType: Expected response type conforming to `Decodable`
    /// - Returns: A publisher that emits the decoded response or an error
    func performRequest<T: Encodable, U: Decodable>(
        url: String,
        method: String,
        payload: T?,
        responseType: U.Type
    ) -> AnyPublisher<U, Error> {
        // Ensure the URL is valid
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the payload if provided
        if let payload = payload {
            do {
                request.httpBody = try JSONEncoder().encode(payload)
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }

        // Create the publisher
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                // Ensure a valid HTTP response
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: U.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
