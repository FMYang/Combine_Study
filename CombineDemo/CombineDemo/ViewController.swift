//
//  ViewController.swift
//  CombineDemo
//
//  Created by yfm on 2023/5/8.
//

import UIKit
import Combine
import Alamofire

class ViewController: UIViewController {
    
    @Published var isLoading: Bool = false
    @Published var cellModels: [CellViewModel] = []
    
    var subscriptions = Set<AnyCancellable>()
    
    let viewModel = ViewModel()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.register(ListCell.self, forCellReuseIdentifier: "cell")
        view.estimatedRowHeight = 70
        view.separatorStyle = .none
        return view
    }()
    
    lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .red
        return view
    }()
    
    lazy var statusView: StateView = {
        let view = StateView()
//        view.isHidden = true
        return view
    }()
    
//    lazy var btn: UIButton = {
//        let btn = UIButton()
//        btn.backgroundColor = .red
//        return btn
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
        loadData()
    }
    
    // 取消单个请求
    func cancelRequest() {
        let url = "https://inshorts.deta.dev/news?category=business"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            // 由于withAllRequests方法是异步调用的（防止阻塞请求的创建），主线程发起的请求马上调用这个方法是找不到的，所以延时下调用
            AF.withAllRequests { requests in
                let find = requests.filter { $0.request?.url?.absoluteString == url }.first
                find?.cancel()
            }
        })
    }
    
    // 取消所有请求
    func cancelAll() {
        AF.cancelAllRequests()
    }
    
    func makeUI() {
        view.addSubview(tableView)
        view.addSubview(activityView)
        view.addSubview(statusView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        statusView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    
    func loadData() {
        // 使用combine
        isLoading = true
        viewModel.fetchData()
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    if let err = error as? AFError {
                        if !err.isExplicitlyCancelledError { // 不是用户取消的
                            if let urlError = err.underlyingError as? URLError, urlError.code == .timedOut {
                                print("timeout")
                            } else {
                                print(error)
                            }
                        } else {
                            // 用户取消的 do nothing
                        }
                    } else if let err = error as? APIError {
                        print(err)
                    }
                case .finished:
                    break
                }
            } receiveValue: { [weak self] models in
                self?.cellModels = models
                self?.tableView.reloadData()
            }
            .store(in: &subscriptions)
        
        // 不使用combine
//        isLoading = true
//        viewModel.fetchWorldWithoutCombine { [weak self] cellModels in
//            self?.isLoading = false
//            self?.cellModels = cellModels
//            self?.tableView.reloadData()
//        } fail: { error in
//            print(error)
//        }
    }
    
    func bindViewModel() {
        $isLoading
            .sink { [weak self] isloading in
                isloading ? self?.activityView.startAnimating() : self?.activityView.stopAnimating()
            }
            .store(in: &subscriptions)
        
        statusView.bind(viewModel: viewModel)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ListCell
        let model = cellModels[indexPath.row]
        cell.bind(viewModel: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if viewModel.state.rawValue < 3 {
//            viewModel.state = Status(rawValue: viewModel.state.rawValue + 1) ?? .normal
//        } else {
//            viewModel.state = .normal
//        }
        cellModels[0].title = "111"
    }
}


