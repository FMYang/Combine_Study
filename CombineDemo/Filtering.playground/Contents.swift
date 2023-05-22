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

example(of: "compactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    
    strings
        .compactMap { Float($0) }
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
    let numbers = (1...10_100).publisher
    
    numbers
        .ignoreOutput()
        .sink(receiveCompletion: {
            print("Completed with: \($0)")
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
    let numbers = (1...9).publisher
    
    numbers
        .first(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: {
            print("Completed with: \($0)")
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "last(where:)") {
    let numbers = (1...9).publisher
    
    numbers
        .last(where: { $0 % 2 == 0 })
        .sink(receiveCompletion: {
            print("Completed with: \($0)")
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "dropFirst") {
    let numbers = (1...10).publisher
    
    numbers
        .dropFirst(8)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "drop(while:)") {
    let numbers = (1...10).publisher
    
    numbers
        .drop(while: { $0 % 5 != 0 })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 3 {
            isReady.send()
        }
    }
}

example(of: "prefix") {
    let numbers = (1...10).publisher

    numbers
        .prefix(2)
        .sink(receiveCompletion: {
            print("Completed with: \($0)")
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
    let numbers = (1...10).publisher

    numbers
        .prefix(while: { $0 < 3 })
        .sink(receiveCompletion: {
            print("Completed with: \($0)")
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    (1...5).forEach { n in
        taps.send(n)
        
        if n == 2 {
            isReady.send()
        }
    }
}

example(of: "throttle") {
    let subject = PassthroughSubject<Int, Never>()
    
    subject
        .eraseToAnyPublisher()
        .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true) // 1s只能收到一次
        .receive(on: RunLoop.main)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)

    // 每秒发射10次
//    Timer.publish(every: 0.1, on: .main, in: .common)
//        .autoconnect()
//        .sink { _ in subject.send(1) }
//        .store(in: &subscriptions)
}
