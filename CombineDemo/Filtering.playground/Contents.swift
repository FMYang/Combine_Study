import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
    let numbers = (1...10).publisher
    
    numbers
        .filter { $0.isMultiple(of: 3) } // 3的倍数允许通过
        .sink { n in
            print("\(n) is a mutiple of 3!")
        }
        .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
    let words = "hey hey there! want to listen to mister mister ?"
        .components(separatedBy: " ")
        .publisher
    
    words
        .removeDuplicates() // 去重
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}
