//
//  StateView.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/12.
//

import UIKit
import Combine

class StateView: UIView {
    
    var subscriptions = Set<AnyCancellable>()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .red
        label.font = .systemFont(ofSize: 36)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func bind(viewModel: ViewModel) {
        viewModel.$state
            .map { $0.title }
            .assign(to: \.text, on: label)
            .store(in: &subscriptions)
        
    }
}
