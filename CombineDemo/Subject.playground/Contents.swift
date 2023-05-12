import Combine
import Foundation

example(of: "PassthroughSubject") {
    enum MyError: Error {
        case test
    }
    
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            // 发送World的时候，可接收的数量累加1，编程max(3)，也就是说最大可接收3个值
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    
    // first subscriber
    let subscriber = StringSubscriber()
    
    let subject = PassthroughSubject<String, MyError>()
    
    subject.subscribe(subscriber)
    
    // second subscriber
    let subscription = subject
        .sink(receiveCompletion: {
            print("Received completion (sink) \($0)")
        }, receiveValue: {
            print("Received value (sink) \($0)")
        }
        )
    
    subject.send("Hello")
    subject.send("World")
    
    // second subscriber canceled
    subscription.cancel()
    
    // only first subscriber can received the value
    subject.send("Still there?")
    
//    subject.send(completion: .failure(MyError.test))
    
    subject.send(completion: .finished)
    subject.send("How about another one?")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    
    let subject = CurrentValueSubject<Int, Never>(0)
    
    subject
        .print() // log
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)
    
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: { print("Second subscrition", $0) })
        .store(in: &subscriptions)
}

example(of: "Dynamically ajusting Demand") {
    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            
            switch input {
            case 1:
                return .max(2) // new max is 2 + 2 = 4
            case 3:
                return .max(1) // new max is 4 + 1 = 5
            default:
                return .none // new max is 5
            }
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()
    subject.subscribe(subscriber)
    
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6) // can not received
}

// 类型擦除
example(of: "Type erasure") {
    var subscriptions = Set<AnyCancellable>()

    let subject = PassthroughSubject<Int, Never>()
   
    // 类型擦除，返回AnyPublisher<Int, Never>类型，AnyPublisher不能发射值
    let publisher = subject.eraseToAnyPublisher()
    
    publisher
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(0)
}
