//
//  ViewModel.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/11.
//

import Foundation
import Combine
import Alamofire

enum MyError: Error {
    case serviceError
    case parseError
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
    
    @Published var loading: Bool = false
    
    @Published var state: Status = .normal
    
//    func fetchData() -> AnyPublisher<[CellViewModel], Never> {
//        // 0...3 -> cellviewmodel -> [cellviewmodel] -> AnyPublisher
//        return (0...3).publisher.map { i in
//            let model = Model(title: "\(i)", content: "\(i)")
//            let cellViewModel = CellViewModel(model: model)
//            return cellViewModel
//        }.collect().eraseToAnyPublisher()
//    }
    
//    func fetchData() -> Future<[CellViewModel], Never> {
//        print("tt1")
//        return Future<[CellViewModel], Never> { promise in
//             DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                 print("tt2")
//                 let list = (0...3).map { i in
//                     let model = Model()
//                     model.title = "\(i)"
//                     model.content = "content-\(i)"
//                     let cellViewModel = CellViewModel(model: model)
//                     return cellViewModel
//                 }
//                 promise(.success(list))
//             })
//         }
//    }
    
    func fetchData() -> AnyPublisher<[CellViewModel], Error> {
        let url = "https://inshorts.deta.dev/news?category=business"
        
        loading = true
        
        // timeout
        let requestModifier: Alamofire.Session.RequestModifier? = {
            $0.timeoutInterval = 5
        }
        
        return AF.request(url, requestModifier: requestModifier)
            .validate()
            .publishDecodable(type: ListModel.self)
            .tryMap { [weak self] response in
                self?.loading = false
                switch response.result {
                case .failure(let error): throw error
                case .success(let list):
                    guard list.success else { throw MyError.serviceError }
                    guard let data = list.data else { throw MyError.parseError }
                    return data.map { CellViewModel(model: $0) }
                }
            }
            .eraseToAnyPublisher()
    }
}
