//
//  WorkTarget.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/19.
//

import Alamofire

protocol NewsTarget: APITarget {

}

extension NewsTarget {
    
    var baseURL: String {
        "https://inshorts.deta.dev"
    }
    
    var params: [String : Any]? {
        nil
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var timeoutInterval: TimeInterval? {
        nil
    }
}
