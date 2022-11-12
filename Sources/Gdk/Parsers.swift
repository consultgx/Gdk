//
//  File.swift
//  
//
//  Created by G on 2022-11-11.
//

import Foundation
import Combine

public enum GError: Error {
    case parsing
    static func parsing(description: String) -> GError {
        GError.parsing
    }
}

public class GParsers {
    
    public static func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, GError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        return Just(data)
          .decode(type: T.self, decoder: decoder)
          .mapError { error in
            .parsing(description: error.localizedDescription)
          }
          .eraseToAnyPublisher()
      }
    
    public static func decode<T:Codable>(from data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}
