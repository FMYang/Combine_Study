import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
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
    let just = Just("Hello world!")
    
    _ = just
        .sink {
            print("Received completion", $0)
        } receiveValue: {
            print("Received value", $0)
        }
}
