//
//  UIButton+Combine.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/15.
//

import UIKit
import Combine

extension UIButton {
    private struct AssociatedKeys {
        static var tapPublisher = "tapPublisher"
    }
    
    private var tapPublisher: PassthroughSubject<Void, Never> {
        if let publisher = objc_getAssociatedObject(self, &AssociatedKeys.tapPublisher) as? PassthroughSubject<Void, Never> {
            return publisher
        }
        
        let publisher = PassthroughSubject<Void, Never>()
        objc_setAssociatedObject(self, &AssociatedKeys.tapPublisher, publisher, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        return publisher
    }
    
    @objc func handleTap() {
        tapPublisher.send()
    }
    
    var publisher: AnyPublisher<Void, Never> {
        tapPublisher.eraseToAnyPublisher()
    }
}
