//
//  ViewModel.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/11.
//

import Foundation
import Combine
import Alamofire

enum APIError: Error {
    case serviceError
    case clientError
    case httpError
}

enum Status: Int {
    case normal
    case downloading
    case uploading
    case complete
    
    var title: String {
        switch self {
        case .normal:
            return "normal"
        case .downloading:
            return "downloading"
        case .uploading:
            return "uploading"
        case .complete:
            return "complete"
        }
    }
}

class ViewModel {
        
    @Published var state: Status = .normal
    
    func fetchData() -> AnyPublisher<[CellViewModel], Error> {
        
//        return fetchWorldAndBusiness()
        
        return fetch(targets: [NewsAPI.business, NewsAPI.world])
        
    }
    
    func fetchWorldWithoutCombine(success: @escaping ([CellViewModel]) -> Void,
                                  fail: @escaping (Error) -> Void) {
        APIService
            .request(target: NewsAPI.business)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let listModel = try? JSONDecoder().decode(ListModel.self, from: data)
                    if listModel?.success == true {
                        if let list = listModel?.data {
                            let cellModels = list.map { CellViewModel(model: $0) }
                            success(cellModels)
                        } else {
                            success([])
                        }
                    } else {
                        fail(APIError.serviceError)
                    }
                case .failure(let afError):
                    fail(afError)
                }
            }
    }
    
    // 请求bussiness + world使用merge合并
    func fetchWorldAndBusiness2() -> AnyPublisher<[CellViewModel], Error> {
        let bussinessPublisher = fetchBussiness()
        let worldPublisher = fetchWorld()
        
        return Publishers
            .Merge(bussinessPublisher, worldPublisher)
            .collect() // [[businesses], [worlds]]
            .map { $0.flatMap { $0 } } // [businesses + worlds]
            .eraseToAnyPublisher()
    }
    
    // 请求bussiness + world使用zip合并
    func fetchWorldAndBusiness() -> AnyPublisher<[CellViewModel], Error> {
        let bussinessPublisher = fetchBussiness()
        let worldPublisher = fetchWorld()

        return bussinessPublisher
            .zip(worldPublisher)
            .map { return $0 + $1 }
            .eraseToAnyPublisher()
    }

    // 请求Bussiness
    func fetchBussiness() -> AnyPublisher<[CellViewModel], Error> {
        return APIService
            .request(target: NewsAPI.business,
                     type: ListModel.self)
            .tryMap { response in
                switch response.result {
                case .failure(let error): throw error
                case .success(let list):
                    guard list.success else { throw APIError.serviceError }
                    guard let data = list.data else { throw APIError.clientError }
                    return data.map { CellViewModel(model: $0) }
                }
            }
            .eraseToAnyPublisher()
    }
    
    // 请求world
    func fetchWorld() -> AnyPublisher<[CellViewModel], Error> {
        return APIService
            .request(target: NewsAPI.world,
                     type: ListModel.self)
            .tryMap { response in
                switch response.result {
                case .failure(let error): throw error
                case .success(let list):
                    guard list.success else { throw APIError.serviceError }
                    guard let data = list.data else { throw APIError.clientError }
                    return data.map { CellViewModel(model: $0) }
                }
            }
            .eraseToAnyPublisher()
    }
    
    // 请求多个使用merge合并
    func fetch(targets: [APITarget]) -> AnyPublisher<[CellViewModel], Error> {
        var requests: [AnyPublisher<[CellViewModel], Error>] = []
        
        for target in targets {
            let request = APIService
                .request(target: target,
                         type: ListModel.self)
                .tryMap { response in
                    switch response.result {
                    case .failure(let error): throw error
                    case .success(let list):
                        guard list.success else { throw APIError.serviceError }
                        guard let data = list.data else { throw APIError.clientError }
                        return data.map { CellViewModel(model: $0) }
                    }
                }
                .eraseToAnyPublisher()
            
            requests.append(request)
        }
        
        return Publishers.MergeMany(requests)
            .collect()
            .map { $0.flatMap { $0} }
            .eraseToAnyPublisher()
    }
}
