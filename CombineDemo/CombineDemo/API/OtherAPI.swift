//
//  OtherAPI.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/19.
//

import Alamofire

enum OtherAPI {
    case list(Int)
}

extension OtherAPI: NewsTarget {
    
    var baseURL: String {
        "https://other.com"
    }
    
    var url: String {
        "/list"
    }
    
    var params: [String : Any]? {
        switch self {
        case .list(let id):
            return ["id": id]
        }
    }
}
