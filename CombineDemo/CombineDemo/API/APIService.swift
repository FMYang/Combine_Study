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
    
    // 请求地址
    var baseURL: String { get }
    
    // 请求地址
    var url: String { get }
    
    // 请求参数
    var params: [String: Any]? { get }
    
    // 请求方法
    var method: HTTPMethod { get }
    
    // 请求头
    var headers: [String: String]? { get }
    
    // 超时时间
    var timeoutInterval: TimeInterval? { get }
}

class APIService {

    // 默认请求头
    static let defaultHeaders: HTTPHeaders = {
        var header = HTTPHeaders()
        header.add(name: "platform", value: "iOS")
        return header
    }()
    
    // Session
    static let alamofire = Session.default
    
    // 公共请求接口 - 使用combine
    static func request<T: Decodable>(target: APITarget,
                                      type: T.Type = T.self,
                                      encoding: ParameterEncoding = URLEncoding.default,
                                      interceptor: RequestInterceptor? = nil) -> AnyPublisher<DataResponse<T, AFError>, Never> {
        // timeout
        var modifier: Session.RequestModifier? = nil
        if let timeoutInterval = target.timeoutInterval {
            modifier = { $0.timeoutInterval = timeoutInterval }
        }
        
        // request headers
        let headers = (target.headers == nil) ? defaultHeaders : HTTPHeaders(target.headers!)
        
        return alamofire.request(target.baseURL + target.url,
                          method: target.method,
                          parameters: target.params,
                          encoding: encoding,
                          headers: headers,
                          interceptor: interceptor,
                          requestModifier: modifier)
        .validate()
        .responseData(completionHandler: { logPrint($0) })
        .publishDecodable(type: type)
        .eraseToAnyPublisher()
    }
    
    // 公共请求接口 - 不使用combine
    static func request(target: APITarget,
                        encoding: ParameterEncoding = URLEncoding.default,
                        interceptor: RequestInterceptor? = nil) -> DataRequest {
        // timeout
        var modifier: Session.RequestModifier? = nil
        if let timeoutInterval = target.timeoutInterval {
            modifier = { url in
                url.timeoutInterval = timeoutInterval
            }
        }
        
        // request headers
        let headers = target.headers == nil ? defaultHeaders : HTTPHeaders(target.headers!)

        return alamofire.request(target.baseURL + target.url,
                          method: target.method,
                          parameters: target.params,
                          encoding: encoding,
                          headers: headers,
                          interceptor: interceptor,
                          requestModifier: modifier)
        .validate()
        .responseData(completionHandler: { logPrint($0) })
    }
    
    // 格式化网络请求结果
    static func logPrint(_ response: AFDataResponse<Data>) {
        let url =  response.request?.url?.absoluteString ?? ""
        let method = response.request?.method?.rawValue ?? "GET"
        var params = "nil"
        if let bodyData = response.request?.httpBody {
           params = String(data: bodyData, encoding: .utf8) ?? "nil"
        }
        let statusCode = response.response?.statusCode ?? -1
        var result: String = ""
        let headers = response.request?.allHTTPHeaderFields ?? [:]
        
        switch response.result {
        case .success(let data):
            result = String(data: data, encoding: .utf8) ?? "nil"
        case .failure(let afError):
            result = afError.errorDescription ?? "nil"
        }
        
        let timeout = response.request?.timeoutInterval.description ?? "0"
        
        var log: String = ""
        log += "============================== Begin Request ==============================\n\n"
        log += "url: \n\(url)\n\n"
        log += "method: \n\(method)\n\n"
        log += "requestHeaders: \n\(headers)\n\n"
        log += "params: \n\(params)\n\n"
        log += "statusCode: \n\(statusCode)\n\n"
        log += "timeout: \n\(timeout)\n\n"
        log += "result: \n\(result)\n\n"
        log += "============================== End Request ==============================\n"
        
        print(log)
    }
}

