//
//  NetworkManager.swift
//  Instagram_IOS
//
//  Created by Pranathi Voora on 1/15/26.
//

import Foundation

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    private let baseURL = "https://dfbf9976-22e3-4bb2-ae02-286dfd0d7c42.mock.pstmn.io"
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    private override init() {
        super.init()
    }
    
    func fetchUserFeed(completion: @escaping (Result<[FeedPost], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/feed") else {
            completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                print("Error details: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                print("Network error: No data received")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
                print("JSON length: \(jsonString.count) characters")
            }
            
            do {
                let decoder = JSONDecoder()
                
                // Try to decode as array first
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("JSON structure: \(type(of: jsonObject))")
                    if let dict = jsonObject as? [String: Any] {
                        print("JSON is a dictionary with keys: \(dict.keys)")
                        // Check if there's a wrapper key like "data" or "posts"
                        if let postsArray = dict["data"] as? [[String: Any]] {
                            print("Found 'data' key with array of \(postsArray.count) items")
                            // Re-encode just the array
                            let arrayData = try JSONSerialization.data(withJSONObject: postsArray)
                            let posts = try decoder.decode([FeedPost].self, from: arrayData)
                            print("Successfully decoded \(posts.count) posts from 'data' key")
                            
                            // Save to Core Data
                            CoreDataManager.shared.saveFeedPosts(posts)
                            
                            DispatchQueue.main.async {
                                completion(.success(posts))
                            }
                            return
                        } else if let postsArray = dict["posts"] as? [[String: Any]] {
                            print("Found 'posts' key with array of \(postsArray.count) items")
                            let arrayData = try JSONSerialization.data(withJSONObject: postsArray)
                            let posts = try decoder.decode([FeedPost].self, from: arrayData)
                            print("Successfully decoded \(posts.count) posts from 'posts' key")
                            
                            // Save to Core Data
                            CoreDataManager.shared.saveFeedPosts(posts)
                            
                            DispatchQueue.main.async {
                                completion(.success(posts))
                            }
                            return
                        } else if let postsArray = dict["feed"] as? [[String: Any]] {
                            print("Found 'feed' key with array of \(postsArray.count) items")
                            let arrayData = try JSONSerialization.data(withJSONObject: postsArray)
                            let posts = try decoder.decode([FeedPost].self, from: arrayData)
                            print("Successfully decoded \(posts.count) posts from 'feed' key")
                            
                            // Save to Core Data
                            CoreDataManager.shared.saveFeedPosts(posts)
                            
                            DispatchQueue.main.async {
                                completion(.success(posts))
                            }
                            return
                        }
                    } else if let array = jsonObject as? [[String: Any]] {
                        print("JSON is directly an array with \(array.count) items")
                    }
                }
                
                // Try direct array decoding
                let posts = try decoder.decode([FeedPost].self, from: data)
                print("Successfully decoded \(posts.count) posts")
                
                // Save to Core Data
                CoreDataManager.shared.saveFeedPosts(posts)
                
                DispatchQueue.main.async {
                    completion(.success(posts))
                }
            } catch let decodingError as DecodingError {
                print("Decoding error: \(decodingError)")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: Expected \(type) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key.stringValue) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                print("Error details: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func fetchReels(completion: @escaping (Result<[Reel], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/user/reels") else {
            completion(.failure(NSError(domain: "NetworkManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                print("Error details: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP error: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                print("Network error: No data received")
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "NetworkManager", code: -3, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received Reels JSON: \(jsonString)")
                print("JSON length: \(jsonString.count) characters")
            }
            
            do {
                let decoder = JSONDecoder()
                
                // Try to decode as ReelsResponse first (wrapped in "reels" key)
                if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("Reels JSON structure: \(type(of: jsonObject))")
                    if let dict = jsonObject as? [String: Any] {
                        print("Reels JSON is a dictionary with keys: \(dict.keys)")
                        // Check if there's a "reels" key
                        if let reelsArray = dict["reels"] as? [[String: Any]] {
                            print("Found 'reels' key with array of \(reelsArray.count) items")
                            // Re-encode just the array
                            let arrayData = try JSONSerialization.data(withJSONObject: reelsArray)
                            let reels = try decoder.decode([Reel].self, from: arrayData)
                            print("Successfully decoded \(reels.count) reels from 'reels' key")
                            
                            // Save to Core Data
                            CoreDataManager.shared.saveReels(reels)
                            
                            DispatchQueue.main.async {
                                completion(.success(reels))
                            }
                            return
                        }
                    }
                }
                
                // Try direct ReelsResponse decoding
                let response = try decoder.decode(ReelsResponse.self, from: data)
                print("Successfully decoded \(response.reels.count) reels")
                
                // Save to Core Data
                CoreDataManager.shared.saveReels(response.reels)
                
                DispatchQueue.main.async {
                    completion(.success(response.reels))
                }
            } catch let decodingError as DecodingError {
                print("Decoding error: \(decodingError)")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type mismatch: Expected \(type) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key.stringValue) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type) at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                case .dataCorrupted(let context):
                    print("Data corrupted at \(context.codingPath)")
                    print("Context: \(context.debugDescription)")
                @unknown default:
                    print("Unknown decoding error")
                }
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                print("Error details: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

// MARK: - URLSessionDelegate
extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // For development: Accept self-signed certificates for the mock API
        if challenge.protectionSpace.host.contains("mock.pstmn.io") {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        // Default behavior for other domains
        completionHandler(.performDefaultHandling, nil)
    }
}
