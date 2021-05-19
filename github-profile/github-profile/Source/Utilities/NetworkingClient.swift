//
//  NetworkingClient.swift
//  github-profile
//
//  Created by Tiago Lopes on 16/05/21.
//

import Foundation

final class NetworkingClient {
    
    // MARK: Properties
    
    private let session = URLSession.shared
    
    // MARK: Public API
    
    func performHttpCall(_ url: URL, completionHandler: @escaping (Result<Data?, AppError>) -> Void) -> CancellableCall {
        let dataTask = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completionHandler(.failure(.connectionFailure))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.unknown))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.responseFailure(response: httpResponse)))
                return
            }
            
            completionHandler(.success(data))
        }
        
        dataTask.resume()
        
        return dataTask
    }
}

protocol CancellableCall {
    func cancel()
}

extension URLSessionDataTask: CancellableCall {}
