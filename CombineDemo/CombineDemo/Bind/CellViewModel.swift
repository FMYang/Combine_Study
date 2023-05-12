//
//  CellViewModel.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/12.
//

import Foundation

class CellViewModel {
    
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var url: String = ""
        
    init(model: Model) {
        title = model.title ?? ""
        content = (model.content ?? "")
        url = model.imageUrl ?? ""
    }
}
