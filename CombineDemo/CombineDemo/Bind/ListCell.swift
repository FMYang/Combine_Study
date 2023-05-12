//
//  ListCell.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/11.
//

import UIKit
import SnapKit
import Combine
import Kingfisher

public let kScreenWidth = UIScreen.main.bounds.size.width
public let kScreenHeight = UIScreen.main.bounds.size.height

class ListCell: UITableViewCell {
    
    var subscriptions = Set<AnyCancellable>()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    lazy var coverImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.text = ""
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        makeUI()
    }
    
    func bind(viewModel: CellViewModel) {
        viewModel.$title.assign(to: \.text!, on: titleLabel).store(in: &subscriptions)
        viewModel.$content.assign(to: \.text!, on: contentLabel).store(in: &subscriptions)
        viewModel.$url
            .map { return URL(string: $0) }
            .sink { [weak self] url in
                if let url = url {
                    self?.coverImageView.kf.setImage(with: .network(url))
                }
            }
            .store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        addSubview(coverImageView)
        addSubview(titleLabel)
        addSubview(contentLabel)
        
        coverImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(kScreenWidth-40)
            make.height.equalTo((kScreenWidth-40) * 606 / 1080)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
}
