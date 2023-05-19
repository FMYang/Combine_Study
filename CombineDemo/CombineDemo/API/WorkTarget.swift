//
//  WorkTarget.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/19.
//

import Alamofire

protocol WorkTarget: APITarget {

}

extension WorkTarget {
    
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
