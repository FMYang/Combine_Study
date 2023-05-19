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
}

extension NewsAPI: WorkTarget {

    var baseURL: String {
        "https://inshorts.deta.dev"
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
        }
    }
}

//enum NewsAPI {
//    case news(String)
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
//        case .news(let category):
//            return ["category": category]
//        }
//    }
//}
