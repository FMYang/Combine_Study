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


example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    [123, 4, 56].publisher
        .map {
            formatter.string(from: NSNumber(integerLiteral: $0)) ?? ""
        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "mapping key paths") {
    struct Coordinate {
        var x: Double
        var y: Double
    }
    
    func powOf(x: Double, y: Double) -> Double {
        return pow((x - y), 2)
    }
    
    let publisher = PassthroughSubject<Coordinate, Never>()
    
    publisher
        .map(\.x, \.y)
        .sink { x, y in
            print("The coordinate at (\(x), \(y)) is in quadrant", powOf(x: x, y: y))
        }
        .store(in: &subscriptions)
    
    publisher.send(Coordinate(x: 2, y: 4))
    publisher.send(Coordinate(x: 5, y: 0))
}

example(of: "tryMap") {
    Just("Directory name that does not exist")
        .tryMap {
            try FileManager.default.contentsOfDirectory(atPath: $0)
        }
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceNil") {
    ["A", nil, "C"].publisher
        .eraseToAnyPublisher()
        .replaceNil(with: "-") // nil值替换为-，可选值序列变为不可选序列，注释看看
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
    let empty = Empty<Int, Never>()
    
    empty
        .replaceEmpty(with: 1) // 注释看看
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "scan") {
    let publisher = (0..<10).publisher
    
    publisher
        .scan(0, { $0 + $1 })
//        .scan(0) { lastest, current in
//            print(lastest, current)
//            return max(0, lastest + current)
//        }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
