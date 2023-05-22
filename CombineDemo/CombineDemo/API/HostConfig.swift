//
//  HostConfig.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/19.
//

import Foundation

enum Environment: String {
    case release = "线上"
    case develop = "开发"
    case test = "测试"
}

enum Host {
    case main
    case image
    case web
    
    var url: String {
        switch self {
        case .main:
            switch HostConfig.shared.curEnv {
            case .release:
                return "https://inshorts.deta.release"
            case .develop:
                return "https://inshorts.deta.dev"
            case .test:
                return "https://inshorts.deta.test"
            }
        case .image:
            switch HostConfig.shared.curEnv {
            case .release:
                return "http://image.com_release"
            case .develop:
                return "http://image.com_develop"
            case .test:
                return "http://image.com_test"
            }
        case .web:
            switch HostConfig.shared.curEnv {
            case .release:
                return "http://web.com_release"
            case .develop:
                return "http://web.com_develop"
            case .test:
                return "http://web.com_test"
            }
        }
    }
}

class HostConfig {
    
    static let shared = HostConfig()
    private init() {}
    
    var curEnv: Environment = .release
    
    private func url(_ host: Host) -> String {
        return host.url
    }
    
    static func url(_ host: Host = .main) -> String {
        return shared.url(host)
    }
}
