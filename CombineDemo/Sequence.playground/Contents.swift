import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "min") {
    let publisher = [1, -50, 246, 0].publisher
    
    publisher
        .print()
        .min()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "min non-Compareable") {
    let publisher = ["12345",
                     "ab",
                     "hello, world"].map { Data($0.utf8) }.publisher
    
    publisher
        .print("publisher")
        .min(by: { $0.count < $1.count })
        .sink(receiveValue: { data in
            let string = String(data: data, encoding: .utf8)!
            print("Smallest data is \(string), \(data.count)")
        })
        .store(in: &subscriptions)
}

example(of: "max") {
    let publisher = ["A", "F", "Z", "E"].publisher
    
    publisher
        .print("publisher")
        .max()
        .sink(receiveValue: { print("Highest value is \($0)") })
        .store(in: &subscriptions)
}


example(of: "reduce") {
    let arr = [1, 2, 3, 4, 5, 6, 6, 6, 6]
    let result = arr.reduce(0, +) // 累加求和，result = 21
    print(result)
        
    // 去重1
    let set = Set(arr)
    print(set)
    
    // 去重2
    let rr = arr.reduce([], { $0.contains($1) ? $0 : $0 + [$1] })
    print(rr)
    
    for (i, v) in arr.enumerated() {
        print(i, v)
    }
    
//    let zip = zip(arr.indices, arr)
//    for (i, v) in zip {
//        print(i, v)
//    }
}
