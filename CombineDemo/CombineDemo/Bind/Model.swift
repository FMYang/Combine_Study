//
//  Model.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/11.
//

import Foundation

struct ListModel: Codable {
    var success: Bool = false
    var category: String?
    var data: [Model]?
}

struct Model: Codable {
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
