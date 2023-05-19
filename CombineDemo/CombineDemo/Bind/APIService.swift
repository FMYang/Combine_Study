//
//  APIService.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/18.
//

import Foundation
import Alamofire
import Combine

protocol APITarget {
    var baseURL: String { get }
    var url: String { get }
    var params: [String: Any]? { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
}

class APIService {

    static let defaultHeaders: HTTPHeaders = {
        var header = HTTPHeaders()
        header.add(name: "platform", value: "iOS")
        return header
    }()
    
    static let alamofire = Session.default
    
    // 使用combine
    static func request<T: Decodable>(target: APITarget,
                                      type: T.Type = T.self,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      interceptor: RequestInterceptor? = nil,
                                      requestModifier: Session.RequestModifier? = nil) -> AnyPublisher<DataResponse<T, AFError>, Never> {
        let headers = target.headers == nil ? defaultHeaders : HTTPHeaders(target.headers!)
        return alamofire.request(target.baseURL + target.url,
                          method: target.method,
                          parameters: target.params,
                          encoding: encoding,
                          headers: headers,
                          interceptor: interceptor,
                          requestModifier: requestModifier)
        .validate()
        .responseData(completionHandler: { logPrint($0) })
        .publishDecodable(type: type)
        .eraseToAnyPublisher()
    }
    
    // 不使用combine
    static func request(target: APITarget,
                        encoding: ParameterEncoding = URLEncoding.default,
                        interceptor: RequestInterceptor? = nil,
                        requestModifier: Session.RequestModifier? = nil) -> DataRequest {
        let headers = target.headers == nil ? defaultHeaders : HTTPHeaders(target.headers!)
        return alamofire.request(target.baseURL + target.url,
                          method: target.method,
                          parameters: target.params,
                          encoding: encoding,
                          headers: headers,
                          interceptor: interceptor,
                          requestModifier: requestModifier)
        .validate()
        .responseData(completionHandler: { logPrint($0) })
    }
    
    // 格式化网络请求结果
    static func logPrint(_ response: AFDataResponse<Data>) {
        let url =  response.request?.url?.absoluteString ?? ""
        var params = "nil"
        if let bodyData = response.request?.httpBody {
           params = String(data: bodyData, encoding: .utf8) ?? "nil"
        }
        let statusCode = response.response?.statusCode ?? -1
        var result: String = ""
        let headers = response.request?.headers.dictionary ?? [:]
        
        switch response.result {
        case .success(let data):
            result = String(data: data, encoding: .utf8) ?? "nil"
        case .failure(let afError):
            result = afError.errorDescription ?? "nil"
        }
        
        var log: String = ""
        log += "============================== Begin Request ==============================\n\r"
        log += "url: \n\(url)\n\n"
        log += "requestHeaders: \n\(headers)\n\n"
        log += "params: \n\(params)\n\n"
        log += "statusCode: \n\(statusCode)\n\n"
        log += "result: \n\(result)\n\n"
        log += "============================== End Request ==============================\n"
        
        print(log)
    }
}

/* ==================== News API ====================== */
enum NewsAPI {
    case business
    case world
}

extension NewsAPI: APITarget {
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
    
    var method: Alamofire.HTTPMethod {
        .get
    }
    
    var headers: [String : String]? {
        nil
    }
}

/* ==================== Other API ====================== */
enum OtherAPI {
    case list(Int)
}

extension OtherAPI: APITarget {
    var baseURL: String {
        "https://inshorts.deta.dev"
    }
    
    var url: String {
        "/news"
    }
    
    var params: [String : Any]? {
        switch self {
        case .list(let id):
            return ["id": id]
        }
    }
    
    var method: Alamofire.HTTPMethod {
        .post
    }
    
    var headers: [String : String]? {
        nil
    }
}

