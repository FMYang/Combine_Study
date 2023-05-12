import Combine
import Foundation

// notification
example(of: "Publisher") {
    var subscriptions = Set<AnyCancellable>()

    let myNotification = Notification.Name("MyNotification")
    
    NotificationCenter.default
        .publisher(for: myNotification, object: nil)
        .sink { _ in
            print("Notification received from a publisher!")
        }
        .store(in: &subscriptions)
    
    NotificationCenter.default.post(name: myNotification, object: nil)
}

example(of: "Just") {
    var subscriptions = Set<AnyCancellable>()
    
    let just = Just("Hello world!")
    
    just
        .sink {
            print("Received completion", $0)
        } receiveValue: {
            print("Received value", $0)
        }
        .store(in: &subscriptions)
    
}

example(of: "assign(to:on)") {
    
    var subscriptions = Set<AnyCancellable>()
    
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    
    let publisher = ["Hello", "world!"].publisher
    
    publisher
        .assign(to: \.value, on: object)
        .store(in: &subscriptions)
}

// KVO的combine写法
example(of: "assign(to:)") {
    class SomeObject {
        @Published var value = 0
    }
    
    let object = SomeObject()
    
    // 监听属性value的改变
    object.$value
        .sink {
            print($0)
        }
    
    // 注意这里没有返回AnyCancellable，因为生命周期是在 @published 属性deinitialize的时候自动管理的
    // assign(to:on) 需要自己释放subscription
    
    // 改变object的$value属性
    (0..<10).publisher
        .assign(to: &object.$value)
}

example(of: "Custom Subscriber") {
    let publisher = (1...6).publisher
    
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(1))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
//            return .none
            return .unlimited
//            return .max(1)
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    publisher.subscribe(subscriber)
}

// Future can be used to asynchronously produce a single result and then complete.

var subscriptions = Set<AnyCancellable>()

example(of: "Future") {
    func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { promise in
          DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            promise(.success(integer + 1))
          }
        }
    }
    
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}


// cancellable测试
func method1() {
    let myNotification = Notification.Name("MyNotification")
    
    NotificationCenter.default
        .publisher(for: myNotification, object: nil)
        .sink { _ in
            print("Notification received from a publisher!")
        }
//        .store(in: &subscriptions)
    
    // 如果不存储cancellable，函数返回后，订阅就取消了
    // 想要保留订阅，可以将cancellable保存到全局变量
}

func method2() {
    NotificationCenter.default.post(name: Notification.Name("MyNotification"), object: nil)
}

method1()
method2()
