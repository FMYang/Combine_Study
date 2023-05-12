import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// 收集所有收到的元素，当上游发布者完成时，发射一个包含所有元素的数组
// eg, A, B, C -> [A, B, C]
// 与RxSwift的toArray相似
example(of: "Collect") {
    ["A", "B", "C", "D"].publisher
        .collect()
//        .collect(2) // 变种，指定每次收集的元素数量
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
