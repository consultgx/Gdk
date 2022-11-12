//
//  Net.swift
//  GApp
//
//  Created by G on 2023-05-03.
//

import Foundation
import Combine
import SwiftUI
import Network

let urlString = "https://jsonplaceholder.typicode.com/todos/1"

class NetData: APIDataFetcher { var fetchedData = MyResponse(userId: 1, id: 1, title: "", completed: false) }
var cancellables = Set<AnyCancellable>()

func fetchData() {
//    NetData().fetch(url: urlString) { result in
//        switch result {
//        case .success(let success):
//            print(success)
//        case .failure(let failure):
//            print(failure)
//        }
//    }
    Task {
        do {
            let data = try await NetData()
                //.fetch()
                .fetchAsyncRetry2()
            print(data)
        } catch {
            print(error)
        }
        
    }
   
    
}




protocol APIDataFetcher {
    associatedtype T: Codable
    var fetchedData: T {get set}
    func fetch(url: String, completion: @escaping (Result<T, Error>) -> Void)
    func fetch(url: String) async -> Result<T, Error>
    func fetch(url: String) -> AnyPublisher<T, Error>
//    func fetchAsyncRetry(n: Int) async throws -> T
    
}

extension HTTPURLResponse {
    var hasSucess: Bool { 200...299 ~= statusCode }
}


struct MyResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

extension APIDataFetcher {
    func fetch() {
        _ = fetchData()
            .sink { completion in
                switch completion {
                case .finished: break
                    
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { myResponse in
                
            }
        
    }
    
    func fetchData() -> AnyPublisher<MyResponse, Error> {
        let url = URL(string: urlString)!
        let publisher = URLSession.shared.dataTaskPublisher(for: url)
        return publisher
            .map { $0.data }
            .decode(type: MyResponse.self, decoder: JSONDecoder())
            .retry(3)
            .eraseToAnyPublisher()
    }
    
    func fetch(url: String) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: URLRequest(url: URL(string: url)!))
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<400).contains(httpResponse.statusCode),
                      let returnable = try? JSONDecoder().decode(T.self, from: data) else {
                    throw URLError(.badServerResponse)
                }
                return returnable
            }
            .eraseToAnyPublisher()
    }
    
    func fetch(url: String, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: url)!)) { data, res, err in
            if let error = err {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let httpResponse = res as? HTTPURLResponse,
                  (200..<400).contains(httpResponse.statusCode),
                  let returnable = try? JSONDecoder().decode(T.self, from: data) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            completion(.success(returnable))
        }.resume()
    }
    
    func fetch(url: String) async -> Result<T, Error> {
        guard let (data, response) = try? await URLSession.shared.data(for: URLRequest(url: URL(string: url)!)) else {
            return .failure(URLError(.badServerResponse))
        }
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<400).contains(httpResponse.statusCode),
              let returnable = try? JSONDecoder().decode(T.self, from: data) else {
            return .failure(URLError(.badServerResponse))
        }
        return .success(returnable)
    }
    
    func fetchAsyncRetry(n: Int) async throws -> T {
        // Perform n attempts, and retry on any failure:
        for _ in 0..<n {
            do {
                return try await performLoading(url: URL(string: "")!)
            } catch {
                // This 'continue' statement isn't technically
                // required, but makes our intent more clear:
                continue
            }
        }
        
        // The final attempt (which throws its error if it fails):
        return try await performLoading(url: URL(string: "")!)
    }
    private func performLoading(url: URL) async throws -> T {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetchAsyncRetry2() async throws -> MyResponse {
        try await Task.retrying {
            let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
            return try JSONDecoder().decode(MyResponse.self, from: data)
        }
        .value
    }
}

extension Task where Failure == Error {
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    let oneSecond = TimeInterval(1_000_000_000)
                    let delay = UInt64(oneSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    
                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}


class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    var isActive = false
    var isExpensive = false
    var isConstrained = false
    var connectionType = NWInterface.InterfaceType.other
    
    init() {
        monitor.pathUpdateHandler = { path in
            self.isActive = path.status == .satisfied
            self.isExpensive = path.isExpensive
            self.isConstrained = path.isConstrained
            
            let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
            self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
        
        monitor.start(queue: queue)
    }
    
    
}

func makeRequest() {
    let config = URLSessionConfiguration.default
    config.allowsExpensiveNetworkAccess = false
    config.allowsConstrainedNetworkAccess = false
    config.waitsForConnectivity = true
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    
    let session = URLSession(configuration: config)
    let url = URL(string: "https://www.apple.com")!
    
    session.dataTask(with: url) { data, response, error in
        print(data)
    }.resume()
}

struct ContentView22: View {
    @EnvironmentObject var network: NetworkMonitor
    
    var body: some View {
        Text(verbatim: """
        Active: \(network.isActive)
        Expensive: \(network.isExpensive)
        Constrained: \(network.isConstrained)
        """)
    }
    
    //    Button("Fetch Data", action: makeRequest)
}
