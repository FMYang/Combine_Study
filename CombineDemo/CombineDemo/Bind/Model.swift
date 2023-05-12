//
//  Model.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/11.
//

import Foundation

//class Model {
//    var title: String = ""
//    var content: String = ""
//
//    init(title: String, content: String) {
//        self.title = title
//        self.content = content
//    }
//}

class ListModel: Codable {
    var success: Bool = false
    var category: String?
    var data: [Model]?
}

class Model: Codable {
    var id: String?
    var title: String?
    var imageUrl: String?
    var date: String?
    var content: String?
    var author: String?
    var readMoreUrl: String?
    var url: String?
    var category: String?
    var createDate: String?
}
