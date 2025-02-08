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
    let session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
    var cancellables = Set<AnyCancellable>()
    
    private init() {}

    /// Generic method to perform API requests using Combine
    /// - Parameters:
    ///   - url: API endpoint URL
    ///   - method: HTTP method (e.g., "POST")
    ///   - payload: Request body as a generic type conforming to `Encodable`
    ///   - responseType: Expected response type conforming to `Decodable`
    /// - Returns: A publisher that emits the decoded response or an error
    func performRequest<T: RequestBody, U: Decodable>(
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
        if let token = UserDetails.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Encode the payload if provided
        if var payload = payload {
            do {
                payload.store_id = UserDetails.storeId
                payload.user_id = UserDetails.userId
                payload.userType = UserDetails.userType
                request.httpBody = try JSONEncoder().encode(payload)
            } catch {
                return Fail(error: error)
                    .eraseToAnyPublisher()
            }
        }
        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                // Ensure a valid HTTP response
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    if let data = output.response as? HTTPURLResponse , data.statusCode == 400 {
                        if let jsonData = try? JSONSerialization.jsonObject(with: output.data) as? [String: Any] {
                            throw URLError(.badServerResponse, userInfo: jsonData)
                        }
                    }
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: U.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    

    func uploadImage<U: Decodable>(
        url: String,
        imageData: Data,
        fileName: String,
        mimeType: String = "image/jpeg",
        responseType: U.Type
    ) -> AnyPublisher<U, Error> {
        // Ensure the URL is valid
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        // Prepare the boundary
        let boundary = UUID().uuidString
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        // Build multipart form data
        var body = Data()
        
        // Add the image file with the key `image`
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Finalize the body with the closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Use Combine to perform the request
        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: U.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func downloadImage(
        from url: String
    ) -> AnyPublisher<Data, Error> {
        // Ensure the URL is valid
        guard let url = URL(string: url) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Use Combine to perform the request
        return session.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .eraseToAnyPublisher()
    }


}

extension NetworkManager {
    
    func uploadImageToServer(imageData: Data, fileName: String, completionHandler: @escaping (UploadResponse?) -> Void) {
       
        let uploadPublisher: AnyPublisher<UploadResponse, Error> = uploadImage(
            url: .uploadImage(),
            imageData: imageData,
            fileName: fileName,
            responseType: UploadResponse.self
        )
        
        uploadPublisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Upload successful")
                case .failure(let error):
                    print("Upload failed with error: \(error)")
                    completionHandler(nil)
                }
            }, receiveValue: { response in
                completionHandler(response)
                print("Server response: \(response)")
            })
            .store(in: &cancellables)
    }
    
}

struct UploadResponse: Decodable {
    let fileName: String

    enum CodingKeys: String, CodingKey {
        case fileName = "file_name"
    }
}


class CustomSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Trust all certificates during development
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

let session = URLSession(configuration: .default, delegate: CustomSessionDelegate(), delegateQueue: nil)
