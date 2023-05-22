//
//  NewsAPI.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/19.
//

import Alamofire

enum NewsAPI {
    case business
    case world
    case sports
}

extension NewsAPI: NewsTarget {
    
    var baseURL: String {
        return HostConfig.url(.image)
        return HostConfig.url()
    }

    var url: String {
        "/news"
    }

    var params: [String : Any]? {
        switch self {
        case .business:
            return ["category": "business"]
        case .world:
            return ["category": "world"]
        case .sports:
            return ["category": "sports"]
        }
    }
}

//enum NewsAPI {
//    case news(category: String, id: Int)
//}
//
//extension NewsAPI: WorkTarget {
//
//    var baseURL: String {
//        "https://inshorts.deta.dev"
//    }
//
//    var url: String {
//         "/news"
//    }
//
//    var params: [String : Any]? {
//        switch self {
//        case let .news(category, id):
//            return ["category": category, "id": id]
//        }
//    }
//}
